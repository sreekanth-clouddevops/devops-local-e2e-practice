# Week 6 – Day 3  
## Helm + Ingress: Publish Flask App Using NGINX Ingress Controller

This document contains **all installation steps, commands, YAML files, and instructions** to expose the Flask Helm App through an Ingress Controller on a kind cluster.

---

## 1. Objective

- Create a Kubernetes cluster with Ingress-enabled ports  
- Install NGINX Ingress Controller  
- Update Helm chart to support Ingress  
- Expose Flask app using custom hostname  
- Test via browser using NodePort-mapped Ingress

---

## 2. Create kind Cluster with Ingress Ports

Create file:

```yaml
# kind-ingress-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    kubeadmConfigPatches:
      - |
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
    extraPortMappings:
      - containerPort: 80
        hostPort: 8081
        protocol: TCP
      - containerPort: 443
        hostPort: 8444
        protocol: TCP
  - role: worker
  - role: worker
```

Create cluster:

```
kind delete cluster --name helm-ingress || true
kind create cluster --name helm-ingress --config kind-ingress-config.yaml
kubectl get nodes
```

---

## 3. Install NGINX Ingress Controller

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/kind/deploy.yaml
kubectl get pods -n ingress-nginx -w
```

Wait until:

```
ingress-nginx-controller READY 1/1 Running
```

---

## 4. Add Ingress Template to Helm Chart

Create:

```
flask-app/templates/ingress.yaml
```

Content:

```yaml
{{- if .Values.ingress.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "flask-app.fullname" . }}-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  rules:
    - host: {{ .Values.ingress.host }}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: {{ include "flask-app.fullname" . }}
                port:
                  number: 80
{{- end }}
```

---

## 5. Update Values.yaml

```
ingress:
  enabled: true
  host: flask.helm.local
```

---

## 6. Deploy the Helm Release

```
kubectl create namespace week6 || true
helm upgrade --install flaskapp ./ --namespace week6
```

Verify:

```
kubectl get pods -n week6
kubectl get svc -n week6
kubectl get ingress -n week6
```

---

## 7. Configure Local DNS

Edit in Windows host:

```
C:\Windows\System32\drivers\etc\hosts
```

Add:

```
127.0.0.1   flask.helm.local
```

---

## 8. Test in Browser

```
http://flask.helm.local:8081
```

Expected output:

```
Hello from Helm Chart!
```

---

## 9. Cleanup (optional)

```
helm uninstall flaskapp -n week6
kind delete cluster --name helm-ingress
```

---

## ✔ Day 3 Completed
Flask Helm Application is now accessible via NGINX Ingress Controller.

