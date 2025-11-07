# Day4: Jenkins → Docker → AWS ECR

## Objectives
- Build a Docker image in Jenkins
- Authenticate to AWS ECR
- Push image tagged by Git commit
- Keep credentials secure via Jenkins Credentials

## Concept Notes
- ECR registry: `<ACCOUNT_ID>.dkr.ecr.<region>.amazonaws.com`
- Login: `aws ecr get-login-password | docker login --username AWS --password-stdin <registry>`
- Tagging strategy: use short Git SHA or build number
- Jenkins credentials binding keeps secrets out of logs

## Folder
Week2/Day4-Jenkins-Docker-ECR/
├── app/
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
└── Jenkinsfile

## Jenkinsfile Highlights
- Parameters: `AWS_REGION`, `ECR_REPO`, `IMAGE_TAG`
- Resolve account ID via `aws sts`
- Login to ECR, docker build, push
- Archives `image.uri` for traceability

## Steps
1) VM prep:
   - `sudo usermod -aG docker jenkins && sudo systemctl restart jenkins`
   - `sudo apt-get install -y awscli`

2) AWS:
   - `aws configure` (access key, secret, region)
   - `aws ecr create-repository --repository-name devops-local-app --region ap-south-1`

3) Jenkins credentials:
   - Add **Username with password** → ID: `aws-ecr-creds`
   - Username = AWS_ACCESS_KEY_ID
   - Password = AWS_SECRET_ACCESS_KEY

4) Jenkins job:
   - Pipeline from SCM
   - Repo: `https://github.com/sreekanth-clouddevops/devops-local-e2e-practice.git`
   - Branch: `feature/Week2`
   - Script path: `Week2/Day4-Jenkins-Docker-ECR/Jenkinsfile`

5) Validate:
   - Console: `Pushed image: <registry>/<repo>:<tag>`
   - AWS CLI: `aws ecr list-images --repository-name <repo> --region <region>`

## Q&A (Interview)
- **Why ECR over Docker Hub?** Private, IAM-based, lifecycle policies, regional.
- **Where are Jenkins workspaces?** `/var/lib/jenkins/workspace/<job>`
- **Secure AWS creds?** Jenkins Credentials + no echoing secrets in logs.
- **How to tag by build number?** Set `IMAGE_TAG = "${BUILD_NUMBER}"` in pipeline.

