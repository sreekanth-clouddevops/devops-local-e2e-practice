# Week 6 – Day 1  
## Helm Basics – Charts, Templates, Values, Install, Upgrade, Rollback

---

## 🎯 Objective
On Day 1 of Week 6, you will learn:

- What is Helm & why DevOps teams use it  
- Create your first Helm chart  
- Understand templates, values, and chart structure  
- Deploy applications using Helm  
- Perform upgrades and rollbacks  
- Manage releases cleanly in Kubernetes  

Everything is executed inside your Vagrant VM.

---

# 1️⃣ Install Helm

Run inside the VM:

```bash
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
helm version
```

---

# 2️⃣ Create Working Directory

```bash
mkdir -p ~/devops-local-e2e-practice/Week6/Day1-Helm-Basics
cd ~/devops-local-e2e-practice/Week6/Day1-Helm-Basics
```

---

# 3️⃣ Create Your First Helm Chart

```bash
helm create mywebapp
```

This generates:

```
mywebapp/
  Chart.yaml
  values.yaml
  templates/
  charts/
```

---

# 4️⃣ Understand Chart Structure

### Chart.yaml  
Metadata about the chart (name, version).

### values.yaml  
Configuration values that templates use.

### templates/  
Contains Kubernetes YAML files with Helm variables.

Example variable in Deployment template:

```
{{ .Values.replicaCount }}
```

---

# 5️⃣ Customize values.yaml

Update service type:

```bash
sed -i 's/NodePort/ClusterIP/' mywebapp/values.yaml
```

Update replica count:

```bash
sed -i 's/replicaCount: 1/replicaCount: 2/' mywebapp/values.yaml
```

---

# 6️⃣ Helm Dry Run (No Deployment Yet)

```bash
helm install test-webapp ./mywebapp --dry-run --debug
```

This allows verifying chart output before applying to the cluster.

---

# 7️⃣ Install Chart to Kubernetes

```bash
helm install webapp ./mywebapp
```

Verify deployment:

```bash
helm list
kubectl get pods
kubectl get svc
```

---

# 8️⃣ Upgrade the Release

Edit values.yaml:

```yaml
replicaCount: 3
```

Apply upgrade:

```bash
helm upgrade webapp ./mywebapp
```

Verify:

```bash
kubectl get deployment
```

---

# 9️⃣ Rollback Release

```bash
helm rollback webapp 1
```

Check Helm release history:

```bash
helm history webapp
```

---

# 🔟 Uninstall Release

```bash
helm uninstall webapp
kubectl get all
```

---

# ✅ Summary

You now understand:

- Helm chart creation  
- Helm templating  
- values.yaml overrides  
- dry-run, install, upgrade, rollback  
- Using Helm instead of raw YAML  

This completes **Week6 – Day1**.

Next → **Week6-Day2: Build a Helm Chart for Flask App (with ECR Image)**

