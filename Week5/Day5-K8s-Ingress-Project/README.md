# Week5 – Day5  
## Kubernetes Project: Ingress + ConfigMap + Secret + ECR App Deployment

---

## 🎯 Objective

In this Day5 mini-project, we deploy a Flask app (image stored in AWS ECR) into the existing `devops-kind` Kubernetes cluster and integrate:

- ConfigMap (APP_MESSAGE, APP_ENV)
- Secret (API_TOKEN)
- Deployment (using ECR private image + readiness/liveness probes)
- Service (ClusterIP)
- Ingress (NGINX Ingress with host → service routing)
- Testing via port-forward (`http://flask.local:8085`)

---

# 1️⃣ Pre-Checks

Use existing kind cluster:

```bash
kubectl config current-context
kubectl get nodes -o wide

Should show:

devops-kind-control-plane
devops-kind-worker
devops-kind-worker2

2️⃣ Install NGINX Ingress Controller

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl get pods -n ingress-nginx

Wait until:

ingress-nginx-controller → Running

3️⃣ Create Namespace

kubectl create namespace week5-ingress
kubectl get ns

4️⃣ ConfigMap & Secret
4.1 ConfigMap — configmap.yaml

apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: week5-ingress
data:
  APP_MESSAGE: "Hello from ConfigMap - Week5 Day5!"
  APP_ENV: "prod"

Apply:

kubectl apply -f configmap.yaml
kubectl get configmap -n week5-ingress

4.2 Secret — secret.yaml

apiVersion: v1
kind: Secret
metadata:
  name: app-secret
  namespace: week5-ingress
type: Opaque
stringData:
  API_TOKEN: "my-super-secret-token"

Apply:

kubectl apply -f secret.yaml
kubectl get secret -n week5-ingress

5️⃣ Configure ECR Image Access

Use the existing Flask image from Week5-Day4:

AWS_REGION=us-east-1
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REPO=week5-flask-app
ECR_REGISTRY="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
IMAGE_TAG=v1
IMAGE_URI="${ECR_REGISTRY}/${ECR_REPO}:${IMAGE_TAG}"
echo $IMAGE_URI

Create ECR Pull Secret

SECRET_NAME=ecr-pull-secret

kubectl create secret docker-registry $SECRET_NAME \
  --docker-server=$ECR_REGISTRY \
  --docker-username=AWS \
  --docker-password="$(aws ecr get-login-password --region $AWS_REGION)" \
  --namespace week5-ingress

6️⃣ Deployment — deployment.yaml

Replace IMAGE_URI_PLACEHOLDER with your $IMAGE_URI.

apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-app
  namespace: week5-ingress
spec:
  replicas: 2
  selector:
    matchLabels:
      app: flask-app
  template:
    metadata:
      labels:
        app: flask-app
    spec:
      imagePullSecrets:
        - name: ecr-pull-secret
      containers:
        - name: flask-container
          image: IMAGE_URI_PLACEHOLDER
          ports:
            - containerPort: 5000
          env:
            - name: APP_MESSAGE
              valueFrom:
                configMapKeyRef:
                  name: app-config
                  key: APP_MESSAGE
            - name: APP_ENV
              valueFrom:
                configMapKeyRef:
                  name: app-config
                  key: APP_ENV
            - name: API_TOKEN
              valueFrom:
                secretKeyRef:
                  name: app-secret
                  key: API_TOKEN
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

Apply:

kubectl apply -f deployment.yaml
kubectl get pods -n week5-ingress -o wide

Pods should be Running.
7️⃣ Service — service.yaml

apiVersion: v1
kind: Service
metadata:
  name: flask-service
  namespace: week5-ingress
spec:
  selector:
    app: flask-app
  ports:
    - port: 80
      targetPort: 5000
  type: ClusterIP

Apply:

kubectl apply -f service.yaml
kubectl get svc -n week5-ingress

8️⃣ Ingress — ingress.yaml

Hostname: flask.local

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: flask-ingress
  namespace: week5-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
    - host: flask.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: flask-service
                port:
                  number: 80

Apply:

kubectl apply -f ingress.yaml
kubectl get ingress -n week5-ingress

9️⃣ Add Host Entry

Inside the VM:

echo "127.0.0.1 flask.local" | sudo tee -a /etc/hosts

🔟 Test the Ingress

Forward port:

kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8085:80

Test:

curl http://flask.local:8085

You should see Flask response:

Hello from Docker + Week5-Day1!

1️⃣1️⃣ Optional Cleanup

kubectl delete -f ingress.yaml
kubectl delete -f service.yaml
kubectl delete -f deployment.yaml
kubectl delete -f configmap.yaml
kubectl delete -f secret.yaml
kubectl delete namespace week5-ingress
