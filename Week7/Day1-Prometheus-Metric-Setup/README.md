Week7 Day1: Prometheus Setup on Kubernetes
🎯 Objective

Set up Prometheus in the Kubernetes cluster to collect metrics for nodes, pods, containers, and system components.

📍 Architecture

Prometheus will deploy:

Prometheus Server → stores time-series data

Alertmanager → handles alerts

Node Exporter → node-level metrics

Kube State Metrics → object metrics (pods, deployments, etc.)

All installed via Helm in the monitoring namespace.

🚀 Step-by-Step Commands
1. Add Prometheus Helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

2. Create monitoring namespace
kubectl create namespace monitoring

3. Install Prometheus
helm install prometheus prometheus-community/prometheus -n monitoring

4. Verify installation
kubectl get pods -n monitoring


Expected pods:

prometheus-server-*

prometheus-kube-state-metrics-*

prometheus-node-exporter-*

prometheus-alertmanager-*

5. Access Prometheus UI

Port-forward:

kubectl port-forward svc/prometheus-server -n monitoring 9090:80

Here is the command to load Prometheus URL from web brower
vagrant@devops-e2e-vm:~$ kubectl port-forward --address 0.0.0.0 svc/prometheus-server -n monitoring 9090:80
Forwarding from 0.0.0.0:9090 -> 9090


Access from Windows:

👉 http://localhost:9090


http://192.168.56.60:9090
🔍 Validate Prometheus Queries

In the “Graph” tab, run:

up
node_cpu_seconds_total
container_memory_usage_bytes
kube_pod_container_info
container_cpu_usage_seconds_total


You should see results if metrics collection is working.

📦 Files Created

No files created manually today — everything is via Helm.

📌 End of Day Summary

You installed and validated:

Prometheus Server

Node Exporter

Kube State Metrics

Alertmanager

Prometheus UI access

Verified core metric queries

This forms the base metrics layer for the entire Week-7 monitoring stack.
