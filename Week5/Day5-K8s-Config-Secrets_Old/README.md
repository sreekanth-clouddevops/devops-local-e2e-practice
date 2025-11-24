# Week5 – Day5  
## Kubernetes ConfigMaps, Secrets & Probes (Flask App from ECR)

---

## 🎯 Objective

Today you will learn:

- How to create & use **ConfigMaps**  
- How to store sensitive data using **Secrets**  
- How to inject ConfigMap + Secret into a Deployment as **environment variables**  
- How to add **readiness** and **liveness** probes  
- How to expose the app using a **NodePort Service** (30082)  
- How to pull a **private ECR image** using `imagePullSecrets`

All commands are executed inside the **Vagrant VM**.

---

## 📁 Folder Structure

```
devops-local-e2e-practice/
└── Week5/
    ├── Day4-K8s-Deploy-App/
    └── Day5-K8s-Config-Secrets/
         ├── kind-cluster.yaml
         ├── namespace.yaml
         ├── configmap.yaml
         ├── secret.yaml
         ├── deployment.yaml
         ├── service.yaml
         └── README.md
```

---

## 1️⃣ Create Folder & Cluster

```bash
cd ~/devops-local-e2e-practice
mkdir -p Week5/Day5-K8s-Config-Secrets
cd Week5/Day5-K8s-Config-Secrets
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

Create cluster:

```bash
kind create cluster --name devops-kind --config kind-cluster.yaml
kubectl get nodes -o wide
```

---

## 2️⃣ Namespace

### namespace.yaml

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: week5-config
```

Apply:

```bash
kubectl apply -f namespace.yaml
```

---

## 3️⃣ ConfigMap & Secret

### 3.1 configmap.yaml

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: week5-config
data:
  APP_GREETING: "Hello from ConfigMap (Week5-Day5)!"
  APP_ENV: "dev"
```

Apply:

```bash
kubectl apply -f configmap.yaml
```

---

### 3.2 secret.yaml

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
  namespace: week5-config
type: Opaque
stringData:
  API_KEY: "super-secret-api-key"
  DB_PASSWORD: "P@ssw0rd123"
```

Apply:

```bash
kubectl apply -f secret.yaml
```

---

## 4️⃣ Prepare ECR Image Variables + Pull Secret

Set variables:

```bash
AWS_REGION=us-east-1
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REPO=week5-flask-app
ECR_REGISTRY="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
IMAGE_TAG=v1
IMAGE_URI="${ECR_REGISTRY}/${ECR_REPO}:${IMAGE_TAG}"
echo $IMAGE_URI
```

Create image pull secret:

```bash
SECRET_NAME="ecr-pull-secret"

kubectl create secret docker-registry "${SECRET_NAME}" \
  --docker-server="${ECR_REGISTRY}" \
  --docker-username="AWS" \
  --docker-password="$(aws ecr get-login-password --region ${AWS_REGION})" \
  --namespace week5-config
```

---

## 5️⃣ Deployment (ConfigMap + Secret + Probes)

### deployment.yaml  
> Replace `YOUR_ECR_IMAGE_URI_HERE` with the value of `$IMAGE_URI`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: week5-config-flask-deploy
  namespace: week5-config
spec:
  replicas: 2
  selector:
    matchLabels:
      app: week5-config-flask
  template:
    metadata:
      labels:
        app: week5-config-flask
    spec:
      imagePullSecrets:
        - name: ecr-pull-secret
      containers:
        - name: app
          image: YOUR_ECR_IMAGE_URI_HERE
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 5000

          env:
            - name: APP_GREETING
              valueFrom:
                configMapKeyRef:
                  name: app-config
                  key: APP_GREETING

            - name: APP_ENV
              valueFrom:
                configMapKeyRef:
                  name: app-config
                  key: APP_ENV

            - name: API_KEY
              valueFrom:
                secretKeyRef:
                  name: app-secret
                  key: API_KEY

            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: app-secret
                  key: DB_PASSWORD

          readinessProbe:
            httpGet:
              path: /
              port: 5000
            initialDelaySeconds: 5
            periodSeconds: 10

          livenessProbe:
            httpGet:
              path: /
              port: 5000
            initialDelaySeconds: 15
            periodSeconds: 20
```

Apply:

```bash
kubectl apply -f deployment.yaml
kubectl get pods -n week5-config -o wide
```

---

## 6️⃣ Service

### service.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: week5-config-flask-service
  namespace: week5-config
spec:
  selector:
    app: week5-config-flask
  type: NodePort
  ports:
    - port: 5000
      targetPort: 5000
      nodePort: 30082
```

Apply:

```bash
kubectl apply -f service.yaml
kubectl get svc -n week5-config
```

---

## 7️⃣ Test the Application

### From Vagrant VM

```bash
curl http://localhost:30082
```

You should see your Flask app response.

---

## 8️⃣ Validate Env Vars

```bash
POD=$(kubectl get pod -n week5-config -l app=week5-config-flask -o jsonpath='{.items[0].metadata.name}')

kubectl exec -it $POD -n week5-config -- /bin/sh
env | grep APP_
env | grep API_KEY
env | grep DB_PASSWORD
exit
```

---

## 9️⃣ Cleanup (Optional)

```bash
kubectl delete -f service.yaml
kubectl delete -f deployment.yaml
kubectl delete -f secret.yaml
kubectl delete -f configmap.yaml
kubectl delete -f namespace.yaml
kind delete cluster --name devops-kind
```

---

## 🔚 Completed Day5  
You now understand:

- ConfigMaps  
- Secrets  
- Environment variable injection  
- Readiness & liveness probes  
- Kubernetes pulling private ECR images  

This completes **Week5: Docker + Kubernetes**.

