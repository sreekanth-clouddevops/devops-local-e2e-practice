# Week 2 – Day 5: Deploy Docker Image from AWS ECR to kind Kubernetes Cluster

## 🎯 Objectives
- Create a kind Kubernetes cluster (1 control-plane + 2 workers)
- Configure Kubernetes to pull private images from AWS ECR
- Deploy the Flask Docker image from Day 4
- Expose the app using NodePort
- Test app from host machine
- Prepare for Jenkins CD integration

---

# 1. Prerequisites
Environment:
- Ubuntu 22.04 Vagrant VM
- Docker installed
- AWS CLI configured (`aws configure`)
- Jenkins installed (optional for pipeline deploy)
- ECR image already pushed (from Day 4)
- kind and kubectl installed

Verify:
```bash
kind --version
kubectl version --client --short
docker --version
aws --version
```

---

# 2. Create the kind Cluster (1CP + 2 Workers)

```bash
mkdir -p ~/devops-local-e2e-practice/Week2/Day5-K8s-Deploy-kind
cd ~/devops-local-e2e-practice/Week2/Day5-K8s-Deploy-kind

cat > kind-config.yaml <<'EOF'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    image: kindest/node:v1.28.2
  - role: worker
    image: kindest/node:v1.28.2
  - role: worker
    image: kindest/node:v1.28.2
EOF

kind create cluster --config kind-config.yaml --name devops-kind
kubectl get nodes -o wide
```

Expected result: 3 nodes (1 control-plane, 2 workers)

---

# 3. Namespace & ECR Image Pull Secret

## Create namespace
```bash
kubectl create namespace demo-app
kubectl config set-context --current --namespace=demo-app
```

## Create ECR pull secret
```bash
AWS_REGION=us-east-1
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REGISTRY="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
SECRET_NAME="ecr-pull-secret"

kubectl create secret docker-registry ${SECRET_NAME} \
  --docker-server=${ECR_REGISTRY} \
  --docker-username=AWS \
  --docker-password="$(aws ecr get-login-password --region ${AWS_REGION})" \
  --docker-email="none" \
  --namespace demo-app
```

## Verify secret
```bash
kubectl get secret ecr-pull-secret -n demo-app -o yaml
```

---

# 4. Deployment & Service Manifest

Create file:

`~/devops-local-e2e-practice/Week2/Day5-K8s-Deploy-kind/deployment-ecr.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo-ecr-deploy
  namespace: demo-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: demo-ecr
  template:
    metadata:
      labels:
        app: demo-ecr
    spec:
      containers:
        - name: demo-ecr
          image: REPLACE_IMAGE_URI
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 5000
      imagePullSecrets:
        - name: ecr-pull-secret
---
apiVersion: v1
kind: Service
metadata:
  name: demo-ecr-svc
  namespace: demo-app
spec:
  type: NodePort
  selector:
    app: demo-ecr
  ports:
    - port: 5000
      targetPort: 5000
      nodePort: 30080
```

---

# 5. Replace Image URI with ECR Image

Use your Day4 tag (example: `540b429`):

```bash
AWS_REGION=us-east-1
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
IMAGE_TAG=540b429
IMAGE_URI="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/devops-local-app:${IMAGE_TAG}"

sed -i "s|REPLACE_IMAGE_URI|${IMAGE_URI}|g" \
~/devops-local-e2e-practice/Week2/Day5-K8s-Deploy-kind/deployment-ecr.yaml

grep image: ~/devops-local-e2e-practice/Week2/Day5-K8s-Deploy-kind/deployment-ecr.yaml
```

Expected:
```
image: 123456789012.dkr.ecr.us-east-1.amazonaws.com/devops-local-app:540b429
```

---

# 6. Deploy to Kubernetes

```bash
kubectl apply -f ~/devops-local-e2e-practice/Week2/Day5-K8s-Deploy-kind/deployment-ecr.yaml
kubectl rollout status deployment/demo-ecr-deploy -n demo-app
kubectl get pods -n demo-app -o wide
kubectl get svc demo-ecr-svc -n demo-app -o wide
```

---

# 7. Test the Application

## Option A — NodePort (if reachable)
```
http://192.168.56.60:30080
```

## Option B — Port-forward (recommended)
```bash
kubectl port-forward svc/demo-ecr-svc 5000:5000 -n demo-app
```

Browser:
```
http://192.168.56.60:5000
```

Expected:
```
Hello from Jenkins → Docker → AWS ECR!
```

---

# 8. Debugging Commands

```bash
kubectl describe pod <pod> -n demo-app
kubectl logs <pod> -n demo-app
kubectl get events -n demo-app --sort-by=.lastTimestamp
kubectl rollout undo deployment/demo-ecr-deploy -n demo-app
```

---

# 9. Optional: Jenkins Deployment Stage

```groovy
stage('Deploy to kind') {
  steps {
    script {
      def image = readFile('image.uri').trim()
      sh """
        kubectl config use-context kind-devops-kind || true

        kubectl create namespace demo-app --dry-run=client -o yaml | kubectl apply -f -

        aws ecr get-login-password --region ${AWS_REGION} \
          | kubectl create secret docker-registry ecr-pull-secret \
            --docker-server=${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com \
            --docker-username=AWS --docker-password-stdin \
            --namespace demo-app || true

        sed "s|REPLACE_IMAGE_URI|${image}|g" Week2/Day5-K8s-Deploy-kind/k8s-files/deployment-ecr.yaml \
          | kubectl apply -f -

        kubectl rollout status deployment/demo-ecr-deploy -n demo-app
      """
    }
  }
}
```

---

# 10. Cleanup

```bash
kind delete cluster --name devops-kind
kubectl config delete-context kind-devops-kind
```

---

# 11. Interview/Knowledge Notes

| Topic | Summary |
|------|---------|
| kind cluster | Lightweight Kubernetes using Docker |
| ECR registry | Private AWS container registry |
| imagePullSecrets | Required for Kubernetes to pull private images |
| NodePort | Simple way to expose apps locally |
| CI/CD flow | Build → Push → Deploy |
| Rollbacks | `kubectl rollout undo` |

---

# ✅ Final Outcome

You have successfully:
- Created a 3-node kind cluster  
- Set up ECR authentication  
- Deployed an ECR image to Kubernetes  
- Exposed and tested the application  
- Prepared your environment for full CI/CD integration

