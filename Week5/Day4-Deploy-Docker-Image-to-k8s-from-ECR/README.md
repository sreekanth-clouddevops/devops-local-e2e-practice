# Week5 – Day4  
## Deploy Flask Docker App (from ECR) to Kubernetes (kind)

---

## 🎯 Objective

In this lab you will:

- Reuse the Flask app image from **Week5–Day1**
- Push the Docker image to **AWS ECR**
- Create a **kind Kubernetes cluster** (1 control plane + 2 workers)
- Deploy the application using a **Deployment**
- Configure Kubernetes to pull a **private ECR image** using an `imagePullSecret`
- Expose the app with a **NodePort Service (30081)**
- Test the app using `curl` inside the Vagrant VM

All commands are executed **inside the Vagrant VM** (`vagrant@devops-e2e-vm`).

---

## 📁 Folder Structure

```
devops-local-e2e-practice/
└── Week5/
    ├── Day1-Docker-Basics/              # Flask app + Dockerfile
    └── Day4-K8s-Deploy-App/
         ├── kind-cluster.yaml
         ├── namespace.yaml
         ├── deployment.yaml
         ├── service.yaml
         └── README.md   <-- this file
```

---

## 1️⃣ Build & Push Docker Image to AWS ECR

### Set AWS/ECR variables

```bash
AWS_REGION=us-east-1
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REPO=week5-flask-app
ECR_REGISTRY="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
IMAGE_TAG=v1
IMAGE_URI="${ECR_REGISTRY}/${ECR_REPO}:${IMAGE_TAG}"
echo "Using ECR Image URI = $IMAGE_URI"
```

### Create the ECR repository (safe to run repeatedly)

```bash
aws ecr create-repository \
  --repository-name "${ECR_REPO}" \
  --region "${AWS_REGION}" \
  || true
```

### Build and tag Docker image (from Day1 folder)

```bash
cd ~/devops-local-e2e-practice/Week5/Day1-Docker-Basics

docker build -t week5-app:latest .
docker tag week5-app:latest "${IMAGE_URI}"
```

### Login to ECR and Push Image

```bash
aws ecr get-login-password --region "${AWS_REGION}" \
  | docker login --username AWS --password-stdin "${ECR_REGISTRY}"

docker push "${IMAGE_URI}"
```

---

## 2️⃣ Create kind Cluster (1 Control Plane + 2 Workers)

```bash
cd ~/devops-local-e2e-practice
mkdir -p Week5/Day4-K8s-Deploy-App
cd Week5/Day4-K8s-Deploy-App
```

### kind-cluster.yaml

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  - role: worker
```

### Create cluster

```bash
kind create cluster --name devops-kind --config kind-cluster.yaml
kubectl get nodes -o wide
```

---

## 3️⃣ Create Namespace & ECR Pull Secret

### namespace.yaml

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: week5-app
```

Apply it:

```bash
kubectl apply -f namespace.yaml
kubectl get ns
```

### Create ImagePullSecret

```bash
SECRET_NAME="ecr-pull-secret"

kubectl create secret docker-registry "${SECRET_NAME}" \
  --docker-server="${ECR_REGISTRY}" \
  --docker-username="AWS" \
  --docker-password="$(aws ecr get-login-password --region ${AWS_REGION})" \
  --namespace week5-app
```

Verify:

```bash
kubectl get secret -n week5-app
```

---

## 4️⃣ Create Deployment & Service

### deployment.yaml

> 🔴 Replace `YOUR_ECR_IMAGE_URI_HERE` with actual `IMAGE_URI`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: week5-flask-deploy
  namespace: week5-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: week5-flask
  template:
    metadata:
      labels:
        app: week5-flask
    spec:
      imagePullSecrets:
        - name: ecr-pull-secret
      containers:
        - name: week5-flask-container
          image: YOUR_ECR_IMAGE_URI_HERE
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 5000
```

Example image line:

```yaml
image: 9538xxxxxxx.dkr.ecr.us-east-1.amazonaws.com/week5-flask-app:v1
```

---

### service.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: week5-flask-service
  namespace: week5-app
spec:
  selector:
    app: week5-flask
  type: NodePort
  ports:
    - port: 5000
      targetPort: 5000
      nodePort: 30081
```

---

## 5️⃣ Apply Manifests

```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

Check status:

```bash
kubectl get pods -n week5-app -o wide
kubectl get svc -n week5-app
```

If you see `ImagePullBackOff`, debug:

```bash
kubectl describe pod <pod-name> -n week5-app
```

---

## 6️⃣ Test the Application

Inside Vagrant VM:

```bash
curl http://localhost:30081
```

Expected:

```
Hello from Docker + Week5-Day1!
```

This verifies:

- Kubernetes successfully pulled private ECR image  
- Deployment is running  
- NodePort routing works  

---

## 7️⃣ Cleanup (Optional)

```bash
kubectl delete -f service.yaml
kubectl delete -f deployment.yaml
kubectl delete -f namespace.yaml
kind delete cluster --name devops-kind
```

Image remains in ECR unless removed manually.

---

## 8️⃣ Git Commit

From repo root:

```bash
cd ~/devops-local-e2e-practice
git add Week5/Day4-K8s-Deploy-App
git commit -m "Week5-Day4: Deploy Flask app from ECR to kind cluster"
git push origin feature/Week5
```

---

## 🧠 Key Concepts Learned

- Docker → ECR → Kubernetes real CI/CD pipeline flow  
- Kubernetes Deployment (replicas, labels, selectors)  
- Kubernetes Service (NodePort)  
- Pulling private images using `imagePullSecrets`  
- kind multi-node cluster setup  
- Debugging image pull issues  

---

## 🎉 End of Week5 – Day4  
Next Up:  
**Week5–Day5 → ConfigMaps, Secrets & Ingress (NGINX)**


