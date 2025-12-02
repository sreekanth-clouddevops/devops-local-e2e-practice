Here is one single README.md file you can copy straight into OneNote.

# Week6 – Day5: GitOps with ArgoCD + Helm (Flask App)

This README covers the complete flow:

- Install ArgoCD on Kind cluster
- Expose ArgoCD UI
- Create ArgoCD Application pointing to your Helm chart in GitHub
- Sync and deploy the Flask app into `week6` namespace
- Expose the Flask app via NodePort for access from Windows host
- Demonstrate GitOps (change in Git → ArgoCD syncs → app updates)

---

## 1. Prerequisites

- Vagrant VM running Ubuntu 22.04
- Kind cluster already created and used in previous days
- kubectl configured and pointing to Kind cluster
- Helm installed
- ArgoCD will be installed in this lab
- Your repo cloned at:
  ```bash
  ~/devops-local-e2e-practice


Flask Helm chart at:

Week6/Day2-Flask-Helm-Chart/flask-app

2. Install ArgoCD

Create namespace:

kubectl create namespace argocd


Install ArgoCD (official manifests):

kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml


Wait for all pods to be running:

kubectl get pods -n argocd


Expected:

argocd-application-controller

argocd-applicationset-controller

argocd-dex-server

argocd-notifications-controller

argocd-redis

argocd-repo-server

argocd-server

All in Running state.

3. Expose ArgoCD UI (NodePort)

Patch argocd-server service type to NodePort:

kubectl patch svc argocd-server -n argocd \
  -p '{"spec": {"type": "NodePort"}}'


Check service:

kubectl get svc -n argocd


Sample output:

NAME            TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
argocd-server   NodePort   10.96.143.238   <none>        80:32202/TCP,443:30367/TCP   ...


Important:

HTTP NodePort → 32202 (port 80)

HTTPS NodePort → 30367 (port 443)

From your Windows host, ArgoCD can be accessed using VM IP:

https://192.168.56.60:30367


(accept the browser certificate warning).

4. Get Initial ArgoCD Admin Password

Inside VM:

kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d; echo


This prints the password for user admin.

5. Login to ArgoCD UI

From Windows, open:

https://192.168.56.60:30367


Login:

Username: admin

Password: value from previous step.

(If you prefer HTTP over a port-forward, you can also use kubectl port-forward, but NodePort is enough for this lab.)

6. Create ArgoCD Application (YAML method)

Create directory for Day5:

mkdir -p ~/devops-local-e2e-practice/Week6/Day5-ArgoCD


Create ArgoCD Application manifest:

vi ~/devops-local-e2e-practice/Week6/Day5-ArgoCD/flaskapp-argocd.yaml


Paste:

apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: flaskapp-argocd
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/sreekanth-clouddevops/devops-local-e2e-practice.git
    targetRevision: feature/Week6
    path: Week6/Day2-Flask-Helm-Chart/flask-app
    helm:
      releaseName: flaskapp
  destination:
    server: https://kubernetes.default.svc
    namespace: week6
  syncPolicy:
    automated:
      prune: true
      selfHeal: true


Apply:

kubectl apply -f ~/devops-local-e2e-practice/Week6/Day5-ArgoCD/flaskapp-argocd.yaml


Check applications:

kubectl get applications -n argocd


Expected:

NAME              SYNC STATUS   HEALTH STATUS
flaskapp-argocd   Synced        Healthy


In ArgoCD UI, you should see flaskapp-argocd with status Synced and Healthy.

7. Verify Flask App Deployment

Check pods in week6 namespace:

kubectl get pods -n week6


Expected (example):

NAME                                  READY   STATUS    RESTARTS   AGE
flaskapp-flask-app-778989bbd9-879zq   1/1     Running   0          ...


The Flask app is now deployed by ArgoCD using the Helm chart from Git.

8. Expose Flask App via NodePort (Access from Windows)

By default, the Helm service is ClusterIP. We change it to NodePort so it’s reachable via the Vagrant VM IP (192.168.56.60).

Get current service:

kubectl get svc -n week6


Example:

NAME                 TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
flaskapp-flask-app   ClusterIP   10.96.x.x     <none>        80/TCP    ...


Patch to NodePort:

kubectl patch svc flaskapp-flask-app -n week6 \
  -p '{"spec": {"type": "NodePort"}}'


Confirm:

kubectl get svc flaskapp-flask-app -n week6


You should now see something like:

NAME                 TYPE       CLUSTER-IP   EXTERNAL-IP   PORT(S)        AGE
flaskapp-flask-app   NodePort   10.96.x.x   <none>        80:3XXXX/TCP   ...


Note the NodePort (for example 30081).

9. Test Flask App from VM

From inside the VM:

curl http://192.168.56.60:3XXXX


Replace 3XXXX with the actual NodePort.

You should see the Flask app response.

10. Test Flask App from Windows Host

From Windows, in browser:

http://192.168.56.60:3XXXX


(Use the same NodePort printed by kubectl get svc.)

Optional – nice hostname:

Edit Windows hosts file:

C:\Windows\System32\drivers\etc\hosts


Add:

192.168.56.60 flask.helm.local


Then from Windows browser:

http://flask.helm.local:3XXXX

11. GitOps Demo – Change via Git, Observe via ArgoCD

On VM, edit Helm values:

cd ~/devops-local-e2e-practice/Week6/Day2-Flask-Helm-Chart/flask-app
vi values.yaml


Example change:

replicaCount: 2


Commit & push:

cd ~/devops-local-e2e-practice
git add Week6/Day2-Flask-Helm-Chart/flask-app/values.yaml
git commit -m "Week6 Day5 - Increase replicas to 2"
git push origin feature/Week6


In ArgoCD UI, the app flaskapp-argocd will detect OutOfSync, then Auto Sync (because syncPolicy.automated is enabled).

Verify in cluster:

kubectl get pods -n week6


You should now see 2 pods for the Flask app.

12. Summary

ArgoCD installed in argocd namespace

Exposed via NodePort and accessed from Windows using:

https://192.168.56.60:<argocd-https-nodeport>

ArgoCD Application (flaskapp-argocd) created pointing to:

Repo: devops-local-e2e-practice

Path: Week6/Day2-Flask-Helm-Chart/flask-app

Flask app deployed to week6 namespace via Helm

Service switched to NodePort:

flaskapp-flask-app → reachable at http://192.168.56.60:<nodeport>

GitOps demonstrated: change in values.yaml → commit & push → ArgoCD syncs → cluster updated.
####kubectl svc port forward for argocd UI#####
vagrant@devops-e2e-vm:~$  kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8082:443
Forwarding from 0.0.0.0:8082 -> 8080
Handling connection for 8082
Handling connection for 8082
############
#####kubectl svc port forward for flask-app##
vagrant@devops-e2e-vm:~$ kubectl port-forward --address 0.0.0.0 svc/flaskapp-flask-app -n week6 8083:80
Forwarding from 0.0.0.0:8083 -> 5000
Handling connection for 8083
###########################
