# Week 6 – Day 2  
## Helm Chart for Flask App (AWS ECR + ConfigMap + Secret)

This README contains *all steps*, *all files*, and *all commands* for Week6–Day2 in a **single file**, ready for copy-paste into OneNote.

---

## 1. Objective

Deploy a Flask application to Kubernetes using a **Helm chart** that includes:

- AWS ECR image
- imagePullSecrets
- ConfigMap (APP_MESSAGE, APP_ENV)
- Secret (API_TOKEN)
- ServiceAccount
- Deployment + Service
- Helm install/upgrade/rollback

All steps run inside **Vagrant VM → devops-e2e-vm**.

---

## 2. Folder Setup

```
mkdir -p ~/devops-local-e2e-practice/Week6/Day2-Flask-Helm-Chart
cd ~/devops-local-e2e-practice/Week6/Day2-Flask-Helm-Chart
helm create flask-app
```

This creates:

```
flask-app/
  Chart.yaml
  values.yaml
  templates/
```

---

## 3. Create Namespace & ECR Pull Secret

```
kubectl create namespace week6 --dry-run=client -o yaml | kubectl apply -f -
```

Set AWS variables:

```
AWS_REGION=us-east-1
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REGISTRY="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
```

Create pull secret:

```
kubectl create secret docker-registry ecr-pull-secret \
  --docker-server="${ECR_REGISTRY}" \
  --docker-username=AWS \
  --docker-password="$(aws ecr get-login-password --region ${AWS_REGION})" \
  -n week6
```

Verify:

```
kubectl get secret ecr-pull-secret -n week6
```

---

## 4. Disable Unused Helm Templates

```
cd flask-app/templates
mv ingress.yaml ingress.yaml.disabled
mv hpa.yaml hpa.yaml.disabled
mv httproute.yaml httproute.yaml.disabled
```

---

## 5. Chart.yaml (Final)

```
apiVersion: v2
name: flask-app
description: A Helm chart for Flask app hosted in AWS ECR
type: application
version: 0.1.0
appVersion: "1.0"
```

Save as:  
`flask-app/Chart.yaml`

---

## 6. Final values.yaml (100% correct version)

Save this entire file as:  
`flask-app/values.yaml`

```yaml
replicaCount: 1

image:
  repository: 953816747017.dkr.ecr.us-east-1.amazonaws.com/week5-flask-app
  tag: "v1"
  pullPolicy: IfNotPresent

imagePullSecrets:
  - name: ecr-pull-secret

nameOverride: ""
fullnameOverride: ""

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: false
  className: ""
  annotations: {}
  hosts:
    - host: "flask-helm.local"
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls: []

httpRoute:
  enabled: false
  parentRefs: []
  hostnames: []
  rules: []

env:
  APP_MESSAGE: "Hello from Helm Chart!"
  APP_ENV: "prod"

secretEnv:
  API_TOKEN: "super-secret-token"

serviceAccount:
  create: true
  annotations: {}
  name: ""

podAnnotations: {}

podSecurityContext: {}

securityContext: {}

resources: {}

nodeSelector: {}

tolerations: []

affinity: {}
```

---

## 7. ConfigMap Template

Create file:

`flask-app/templates/configmap.yaml`

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "flask-app.fullname" . }}-config
data:
  APP_MESSAGE: "{{ .Values.env.APP_MESSAGE }}"
  APP_ENV: "{{ .Values.env.APP_ENV }}"
```

---

## 8. Secret Template

Create file:  
`flask-app/templates/secrets.yaml`

```
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "flask-app.fullname" . }}-secret
type: Opaque
stringData:
  API_TOKEN: "{{ .Values.secretEnv.API_TOKEN }}"
```

---

## 9. Deployment Template (Final Correct Version)

Save as:  
`flask-app/templates/deployment.yaml`

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "flask-app.fullname" . }}
  labels:
    {{- include "flask-app.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "flask-app.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "flask-app.selectorLabels" . | nindent 8 }}
    spec:
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}

      serviceAccountName: {{ include "flask-app.serviceAccountName" . }}

      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}

          ports:
            - name: http
              containerPort: 5000
              protocol: TCP

          env:
            - name: APP_MESSAGE
              valueFrom:
                configMapKeyRef:
                  name: {{ include "flask-app.fullname" . }}-config
                  key: APP_MESSAGE

            - name: APP_ENV
              valueFrom:
                configMapKeyRef:
                  name: {{ include "flask-app.fullname" . }}-config
                  key: APP_ENV

            - name: API_TOKEN
              valueFrom:
                secretKeyRef:
                  name: {{ include "flask-app.fullname" . }}-secret
                  key: API_TOKEN
```

---

## 🔟 Service Template

Save as:  
`flask-app/templates/service.yaml`

```
apiVersion: v1
kind: Service
metadata:
  name: {{ include "flask-app.fullname" . }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: http
  selector:
    {{- include "flask-app.selectorLabels" . | nindent 4 }}
```

---

# 11. Install Helm Release

```
cd ~/devops-local-e2e-practice/Week6/Day2-Flask-Helm-Chart
helm install flaskapp ./flask-app -n week6 --create-namespace
```

Check:

```
kubectl get pods -n week6
kubectl get svc -n week6
```

Pod status must be:

```
Running
```

---

# 12. Upgrade Helm Release (after editing values.yaml)

```
helm upgrade flaskapp ./flask-app -n week6
```

---

# 13. Helm History & Rollback

```
helm history flaskapp -n week6
helm rollback flaskapp 1 -n week6
```

---

# 14. Uninstall & Cleanup

```
helm uninstall flaskapp -n week6
kubectl delete namespace week6
```

---

# ✔ Day2 Complete — Summary

You learned:

- Helm chart creation
- ConfigMap + Secret integration
- ECR imagePullSecrets
- Deployment + Service templates
- Helm install, upgrade, rollback  
- ECR image deployment to Kubernetes

This FULL README.md is ready for OneNote — **copy/paste as-is**.


