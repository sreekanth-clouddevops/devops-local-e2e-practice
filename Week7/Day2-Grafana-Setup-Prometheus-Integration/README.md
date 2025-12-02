Week7 Day2: Grafana Setup + Prometheus Integration
🎯 Objective

Install Grafana, integrate it with Prometheus, and import dashboards to visualize Kubernetes cluster metrics.

🚀 Step-by-Step Setup
1. Add Grafana Helm repository
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

2. Create monitoring namespace
kubectl create namespace monitoring || true

3. Install Grafana via Helm
helm install grafana grafana/grafana -n monitoring


Check pods:

kubectl get pods -n monitoring


Expected:

grafana-xxxxx Running

4. Get Grafana admin password
kubectl get secret grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 --decode; echo

5. Access Grafana UI

Port-forward:

kubectl port-forward svc/grafana -n monitoring 3000:80

kubectl port-forward --address 0.0.0.0 svc/grafana -n monitoring 3000:80


Open in browser:

👉 http://localhost:3000

http://192.168.56.60:3000


User: admin
Password: (from previous command)

🔌 Configure Prometheus as Data Source

In Grafana UI:

Connections → Add Data Source

Choose Prometheus

Set URL:

http://prometheus-server.monitoring.svc.cluster.local


Click Save & Test

Should show "Data source is working".

📊 Import Dashboards

Grafana → Dashboards → Import

Use dashboard IDs:

ID	Description
6417	Kubernetes Cluster Monitoring
3662	Node Exporter Full Dashboard
315	Prometheus Statistics
15760	Kubernetes Deployments Metrics

After import, you will see:

Node CPU/Memory

Pod CPU/Memory

K8s cluster health

Prometheus internal stats

📌 Summary of Day 2

You successfully installed & configured:

Grafana

Connected Prometheus

Added official dashboards

Visualized node and pod metrics

This sets up the complete observability visualization layer of your cluster.
