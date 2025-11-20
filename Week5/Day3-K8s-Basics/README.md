# Week5 – Day3  
## Kubernetes Basics with kind (1 Control Plane + 2 Workers)

---

## 🎯 Objective

In Day3 you will:

- Install kind (Kubernetes in Docker)
- Create a 3-node cluster  
- Deploy NGINX on Kubernetes  
- Expose app using NodePort  
- Test scaling and service access  
- Understand Pods, Deployments, Services  

---

## 📂 Project Structure

```
Week5/
 └── Day3-K8s-Basics/
       ├── kind-cluster.yaml
       ├── nginx-deployment.yaml
       ├── nginx-service.yaml
       └── README.md
```

---

## 🚀 Step 1 — Create Folder

```bash
cd ~/devops-local-e2e-practice
mkdir -p Week5/Day3-K8s-Basics
cd Week5/Day3-K8s-Basics
```

---

## 🚀 Step 2 — Install kind

```bash
curl -Lo kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-amd64
chmod +x kind
sudo mv kind /usr/local/bin/
```

---

## 🚀 Step 3 — Create 3-node cluster

`kind-cluster.yaml`:

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
```

Check nodes:

```bash
kubectl get nodes -o wide
```

---

## 🚀 Step 4 — Deploy NGINX App

`nginx-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deploy
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-app
  template:
    metadata:
      labels:
        app: nginx-app
    spec:
      containers:
      - name: nginx
        image: nginx:stable
        ports:
        - containerPort: 80
```

Apply:

```bash
kubectl apply -f nginx-deployment.yaml
kubectl get pods -o wide
```

---

## 🚀 Step 5 — Expose as NodePort

`nginx-service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx-app
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
```

Apply:

```bash
kubectl apply -f nginx-service.yaml
kubectl get svc
```

---

## 🚀 Step 6 — Test Service

Inside Vagrant VM:

```bash
curl http://localhost:30080
```

Should output NGINX HTML.

---

## 🚀 Step 7 — Scale Deployment

```bash
kubectl scale deployment nginx-deploy --replicas=4
kubectl get pods -o wide
```

---

## 🚀 Step 8 — Cleanup

```bash
kubectl delete -f nginx-service.yaml
kubectl delete -f nginx-deployment.yaml
kind delete cluster --name devops-kind
```

---

## ✅ Summary

By finishing Day3, you understand:

✔ Kubernetes components (nodes, pods, deployments, services)  
✔ How kind cluster works  
✔ Deploying + exposing applications  
✔ Scaling deployments  
✔ Accessing via NodePort  

---

