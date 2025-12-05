Week7 – Day3
Loki + Promtail Setup (Fix CrashLoopBackOff) + Validation

This document contains all steps required to install Loki, fix Promtail “too many open files” errors, and validate the full logging stack.

🚀 Step-by-Step Setup
1. Create the monitoring namespace
kubectl create namespace monitoring

2. Install Loki (without Prometheus and Grafana inside this chart)
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm upgrade --install loki grafana/loki-stack \
  --namespace monitoring \
  --set grafana.enabled=false \
  --set prometheus.enabled=false

3. Check Loki + Promtail pods
kubectl get pods -n monitoring


If Promtail pods enter CrashLoopBackOff and kubectl logs shows:

error="failed to make file target manager: too many open files"


then apply the fix below.

🛠️ Fix Promtail Crash: Increase Linux inotify limits

Promtail watches container log files on the Kubernetes nodes.
The default Linux limit is too low on Vagrant + Kind clusters, so Promtail fails.

4. Increase the inotify limit inside the Vagrant VM
sudo sysctl fs.inotify.max_user_instances=8192
sudo sysctl fs.inotify.max_user_watches=524288


To make it permanent:

echo "fs.inotify.max_user_instances=8192" | sudo tee -a /etc/sysctl.conf
echo "fs.inotify.max_user_watches=524288" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

5. Restart Promtail
kubectl rollout restart daemonset loki-promtail -n monitoring


Then wait and check:

kubectl get pods -n monitoring -o wide


You should see all Promtail pods in Running state on all nodes.

Example (expected output sample):

loki-promtail-xxxxx   1/1   Running
loki-promtail-yyyyy   1/1   Running
loki-promtail-zzzzz   1/1   Running

✔️ Validation After Fix
6. Check Loki statefulset
kubectl get statefulset -n monitoring


Expected:

loki   1/1   Running

7. Check Promtail logs (should not show “too many open files”)
kubectl logs <promtail-pod-name> -n monitoring | head


It should start normally.

🎯 Final Working Setup Example (your cluster)

After applying the fix, your pods should look like this:

loki-0                                 Running
loki-promtail-brjwj                    Running
loki-promtail-lnjzs                    Running
loki-promtail-rh9vm                    Running


All Promtail pods are now healthy.

🎉 Week7-Day3 Completed

You have successfully:

Installed Loki on Kubernetes

Installed Promtail DaemonSet

Fixed Promtail CrashLoopBackOff caused by inotify file limits

Verified that logging pipeline is working end-to-end
