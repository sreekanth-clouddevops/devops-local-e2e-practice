Here is the full Day5 README.md in a single block:

# Week7 – Day5 – Final Kubernetes Observability (Prometheus + Grafana + Loki)

## Goal
This day completes the Kubernetes monitoring stack by integrating metrics, logs, and alerting into a single Grafana dashboard. We will use Prometheus for metrics, Loki for logs, and Grafana for visualization and alerting.

---

## Step 1: Verify Monitoring Components

```bash
kubectl get pods -n monitoring -o wide
kubectl get svc -n monitoring


Make sure Prometheus, Grafana, Loki, and Promtail are running.

Step 2: Access Grafana from Windows

Run in VM:

kubectl port-forward --address 0.0.0.0 svc/grafana -n monitoring 3000:80


Access from Windows:

http://192.168.56.60:3000

Step 3: Configure Prometheus Datasource in Grafana

Go to Grafana → Connections → Data sources → Add Prometheus

URL:

http://prometheus-server.monitoring.svc.cluster.local


Auth: No Authentication

TLS: Disabled

Click Save & Test → Should be successful

Step 4: Configure Loki Datasource

Add new datasource → Loki

URL:

http://loki:3100


Auth: No Authentication

TLS: Disabled

Save & Test may show a failure due to Loki version, but Loki is reachable internally.

Validate inside Grafana pod:

kubectl exec -it $(kubectl get pod -n monitoring -l app.kubernetes.io/name=grafana -o jsonpath="{.items[0].metadata.name}") -n monitoring -- sh
wget -O- http://loki:3100/ready
wget -O- http://loki:3100/loki/api/v1/status/buildinfo

Step 5: Create Final Observability Dashboard
Panel 1 – CPU Usage per Node
sum(rate(container_cpu_usage_seconds_total{container!="",pod!=""}[5m])) by (node)

Panel 2 – Memory Usage per Node (GiB)
sum(container_memory_working_set_bytes{container!="",pod!=""}) by (node) / 1024 / 1024 / 1024

Panel 3 – Node Filesystem Utilization
100 - ((node_filesystem_avail_bytes{mountpoint="/"} * 100) / node_filesystem_size_bytes{mountpoint="/"})

Panel 4 – Pod CPU Usage (Top 10)
topk(10, rate(container_cpu_usage_seconds_total{container!="",pod!=""}[5m]))

Panel 5 – Pod Memory Usage (Top 10)
topk(10, container_memory_working_set_bytes{container!="",pod!=""})

Panel 6 – Loki Logs Panel

LogQL:

{namespace="week6"} |= ""

Panel 7 – API Server Latency
histogram_quantile(0.99, sum(rate(apiserver_request_duration_seconds_bucket[5m])) by (le, verb))

Panel 8 – Prometheus Scrape Health
up


Save Dashboard as:

Week7 – Final Observability Dashboard

Step 6: Prometheus Alerts

Create alert-rules.yaml:

groups:
  - name: node-alerts
    rules:
      - alert: HighCPUUsage
        expr: sum(rate(container_cpu_usage_seconds_total[5m])) > 80
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High CPU Usage"
          description: "CPU usage above 80%."

      - alert: HighMemoryUsage
        expr: (sum(container_memory_working_set_bytes) / sum(node_memory_MemTotal_bytes)) > 0.90
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High Memory Usage"
          description: "Cluster memory usage above 90%."


Apply:

kubectl apply -f alert-rules.yaml -n monitoring

Step 7: Grafana Alerts

Grafana → Alerting → New Alert Rule

Query: up

Condition: last() < 1

Frequency: 1 minute

Notification: Default contact point

Step 8: Validate Observability End-to-End
Logs:
kubectl logs -n week6 -l app=flask-app

Metrics (open Prometheus targets):
kubectl port-forward svc/prometheus-server -n monitoring 9090:80


Visit:

http://192.168.56.60:9090/targets

Final Result

You now have a full Kubernetes observability platform with:

✔️ Prometheus Metrics
✔️ Loki Logs
✔️ Grafana Dashboards
✔️ Prometheus Alerts
✔️ Grafana Alerts

This completes Week7 – Day5 successfully.
