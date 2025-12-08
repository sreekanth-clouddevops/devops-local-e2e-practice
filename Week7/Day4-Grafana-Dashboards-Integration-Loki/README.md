FINAL README.md (Single File for OneNote)

Copy everything below exactly as-is:

# Week7 – Day4 – Grafana Dashboards Integration (Prometheus + Loki)

## 1. Overview
This day focuses on connecting Grafana with Prometheus and Loki, exposing Grafana to the Windows host machine, validating internal Loki connectivity, and building Kubernetes observability dashboards. Loki’s health check may show errors in Grafana because the Loki version included in the deprecated `loki-stack` Helm chart is old. However, Loki is reachable internally and can still be queried.

---

## 2. Prerequisites
Already installed in namespace `monitoring`:
- Prometheus (server + alertmanager + exporters)
- Grafana
- Loki + Promtail
- Access to Grafana from Windows host
- Kind cluster running (`devops-kind`)
- Ubuntu VM (Vagrant) IP: **192.168.56.60**

Verify environment:

```bash
kubectl get pods -n monitoring
kubectl get svc -n monitoring

3. Exposing Grafana to Windows (Port Forward)

Run this inside the Vagrant VM:

kubectl port-forward --address 0.0.0.0 svc/grafana -n monitoring 3000:80


From the Windows host, open:

http://192.168.56.60:3000


Login using Grafana credentials.

4. Configure Prometheus Data Source

In Grafana:

Left Menu → Connections → Data sources → Add data source

Choose Prometheus

Set:

Field	Value
Name	prometheus
URL	http://prometheus-server.monitoring.svc.cluster.local
Auth	No Authentication
TLS	Disabled

Click Save & Test → Should be Successful

5. Configure Loki Data Source (Health Check Warning Expected)

In Grafana:

Add Data Source → Loki

Set:

Field	Value
Name	loki
URL	http://loki:3100
Auth	No Authentication
TLS	Disabled

Click Save & Test
→ The health check may show:
“Unable to connect with Loki”
This is expected because the Loki version is old and has API incompatibilities.

But Loki is actually reachable inside Grafana. Test internal connectivity:

kubectl exec -it $(kubectl get pod -n monitoring -l app.kubernetes.io/name=grafana -o jsonpath="{.items[0].metadata.name}") -n monitoring -- sh

# Inside Grafana container
wget -O- http://loki:3100/ready
wget -O- http://loki:3100/loki/api/v1/status/buildinfo


Both commands should return valid responses like "ready" and "version".

Thus Loki queries may still work despite the UI warning.

6. Create Kubernetes Cluster Dashboard (Prometheus)
Panel 1 – Cluster CPU Usage (cores)

PromQL:

sum(rate(container_cpu_usage_seconds_total{container!="",pod!=""}[5m]))


Panel Title: Cluster CPU Usage (cores)
Visualization: Time Series

Panel 2 – Cluster Memory Usage (GiB)

PromQL:

sum(container_memory_working_set_bytes{container!="",pod!=""}) / 1024 / 1024 / 1024


Panel Title: Cluster Memory Usage (GiB)
Visualization: Time Series

Panel 3 – Pods Per Namespace

PromQL:

count(kube_pod_info) by (namespace)


Panel Title: Pods per Namespace
Visualization: Bar Chart / Table

Save the dashboard as:

Week7 - Day4 - K8s Metrics Overview

7. Optional – Loki Logs Dashboard (Only if Queries Work)

Even though “Save & Test” shows error, Loki logs may still work.

Try in Grafana Explore:

{namespace="monitoring"}


If logs appear, create a dashboard:

Loki Logs Panel (Optional)

LogQL:

{namespace="monitoring"} |= ""


Visualization: Logs

Save as:

Week7 - Day4 - Loki Logs Overview


If Loki logs don’t load, skip this section.

8. Summary

Grafana is exposed at http://192.168.56.60:3000

Prometheus datasource works fully.

Loki datasource may show a Grafana health error but is internally reachable.

Created:

Kubernetes Metrics Overview Dashboard

Optional Loki Logs Dashboard

The health error does not block dashboard creation or cluster observability.
