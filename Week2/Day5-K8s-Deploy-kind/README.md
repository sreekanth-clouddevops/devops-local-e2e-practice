# Day5: Deploy to kind (1 control-plane + 2 workers) and ECR image deployment

## Objectives
- Create a local kind cluster (1 control-plane, 2 workers)
- Configure Kubernetes imagePullSecret for AWS ECR
- Deploy your Docker image pushed to ECR (from Day4)
- Verify app via port-forward or NodePort
- Integrate deployment stage into Jenkins pipeline

## Key Steps (summary)
1. Create kind cluster using `kind-config.yaml`
2. Create namespace `demo-app`
3. Create docker-registry secret using `aws ecr get-login-password`
4. Apply `deployment-ecr.yaml` (with image URI pointing to ECR image)
5. Port-forward or expose using NodePort
6. Add `Deploy to kind` stage into Jenkins pipeline

## Files
- kind-config.yaml
- deployment-ecr.yaml
- (Jenkinsfile changes to add Deploy stage)

## Example commands
# Create cluster
kind create cluster --config kind-config.yaml --name devops-kind

# Create namespace and secret
kubectl create namespace demo-app
aws ecr get-login-password --region <REGION> | kubectl create secret docker-registry ecr-pull-secret \
  --docker-server=<ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com \
  --docker-username=AWS --docker-password-stdin --namespace demo-app

# Apply manifest
kubectl apply -f deployment-ecr.yaml
kubectl rollout status deployment/demo-ecr-deploy -n demo-app

# Test locally via port-forward
kubectl port-forward svc/demo-ecr-svc 5000:5000 -n demo-app

## Troubleshooting
- Image pull errors: check secret exists, region & account correct, ECR permissions for IAM user
- kubectl context: ensure `kubectl config current-context` is `kind-devops-kind`
- Jenkins user permissions: ensure Jenkins user has kubeconfig at `/var/lib/jenkins/.kube/config` with correct ownership

## Useful commands
kubectl get pods -n demo-app
kubectl describe pod <pod> -n demo-app
kubectl logs <pod> -n demo-app
kubectl get svc demo-ecr-svc -n demo-app
kubectl rollout undo deployment/demo-ecr-deploy -n demo-app

