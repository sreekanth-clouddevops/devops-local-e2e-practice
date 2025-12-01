# Week6 – Day4: Helm + Jenkins CI/CD Pipeline

This README contains the complete end-to-end steps to build a Helm CI/CD pipeline using Jenkins that validates, packages, and deploys the Flask Helm Chart into a Kubernetes Kind cluster.

---

## 1. Prerequisites

Ensure the following requirements are already working:

- Docker installed
- Kind cluster created earlier (kind-devops-kind)
- kubectl installed and pointing to the cluster
- Helm installed
- Jenkins running on your VM
- devops-local-e2e-practice GitHub repo accessible
- Flask Helm chart available at:

devops-local-e2e-practice/Week6/Day2-Flask-Helm-Chart/flask-app

---

## 2. Fix Chart.yaml (Mandatory for Helm Lint)

Navigate to the Helm chart directory:

```bash
cd ~/devops-local-e2e-practice/Week6/Day2-Flask-Helm-Chart/flask-app

Edit Chart.yaml:

apiVersion: v2
name: flask-app
description: A demo Flask application deployed with Helm
type: application
version: 0.1.0
appVersion: "1.0.0"


Run lint:

helm lint .


Expected:
1 chart(s) linted, 0 chart(s) failed

3. Push Changes to GitHub
cd ~/devops-local-e2e-practice
git add .
git commit -m "Week6 Day4 - Fix Chart.yaml & add Jenkins CI/CD"
git push origin feature/Week6

4. Jenkins Job Setup

In Jenkins:

Create New Item → Pipeline

Select Pipeline script from SCM

SCM = Git

Repo URL:

https://github.com/sreekanth-clouddevops/devops-local-e2e-practice.git


Branch Specifier:

*/feature/Week6


Script Path:

Week6/Day4-Helm-Jenkins-CICD/Jenkinsfile


Save

5. Create Jenkinsfile

Create CICD directory:

mkdir -p ~/devops-local-e2e-practice/Week6/Day4-Helm-Jenkins-CICD


Create Jenkinsfile:

vi ~/devops-local-e2e-practice/Week6/Day4-Helm-Jenkins-CICD/Jenkinsfile


Paste below:

pipeline {
    agent any

    environment {
        CHART_DIR = "Week6/Day2-Flask-Helm-Chart/flask-app"
        RELEASE_NAME = "flaskapp"
        NAMESPACE = "week6"
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Helm Version') {
            steps {
                sh 'helm version'
                sh 'kubectl config current-context'
            }
        }

        stage('Helm Lint') {
            steps {
                dir("${CHART_DIR}") {
                    sh 'helm lint .'
                }
            }
        }

        stage('Helm Package') {
            steps {
                dir("${CHART_DIR}") {
                    sh 'helm package .'
                }
            }
        }

        stage('Helm Deploy') {
            steps {
                sh """
                kubectl create namespace ${NAMESPACE} || true
                helm upgrade --install ${RELEASE_NAME} ${CHART_DIR} --namespace ${NAMESPACE}
                """
            }
        }
    }

    post {
        success {
            echo "Deployment Successful!"
        }
        failure {
            echo "Deployment Failed!"
        }
    }
}

6. Run Jenkins Pipeline

Open Jenkins → select the job:

week6-day4-helm-cicd → Build Now


The stages should run in this order:

Checkout Code

Helm Version

Helm Lint

Helm Package

Helm Deploy

7. Validate Deployment

Check pods:

kubectl get pods -n week6


Check service:

kubectl get svc -n week6


Check ingress (if configured earlier):

kubectl get ingress -n week6

8. Test the Application

Add host entry:

echo "127.0.0.1 flask.helm.local" | sudo tee -a /etc/hosts


Access app:

curl http://flask.helm.local:8081


Expected: Flask welcome message.

9. Completion

✔ Helm chart validated
✔ Jenkins CI/CD automated
✔ Helm deploy executed successfully
✔ Application deployed in week6 namespace
