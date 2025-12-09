Below is the complete README.md in one code block for easy paste into OneNote:

# Week8 – Day2  
# CI Pipeline Security (Jenkins + Trivy Integration)

## 🎯 Objective
Integrate Trivy container scanning inside Jenkins CI pipeline so that builds automatically fail when HIGH or CRITICAL vulnerabilities are found. This is a core DevSecOps practice known as **Shift-Left Security**.

---

## ✅ 1. Trivy Installation Check (Jenkins Node)

Ensure Trivy is installed on the Jenkins server/agent:

```bash
trivy --version


If not:

sudo install -m 755 ./trivy /usr/local/bin/trivy

✅ 2. Create a Sample Vulnerable Docker App
mkdir -p Week8/Day2-Jenkins-Trivy
cd Week8/Day2-Jenkins-Trivy

Dockerfile
FROM python:3.10-slim

RUN pip install flask==2.0.1 requests==2.19.1

COPY app.py /app.py

CMD ["python3", "app.py"]

app.py
from flask import Flask
app = Flask(__name__)

@app.route("/")
def home():
    return "Hello from Vulnerable App!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

✅ 3. Jenkins Pipeline (Jenkinsfile)
pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git branch: 'feature/Week8', url: 'https://github.com/sreekanth-clouddevops/devops-local-e2e-practice.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
		cd Week8/Day2-Jenkins-Trivy
                docker build -t trivy-demo-app:latest .
                '''
            }
        }

        stage('Trivy Scan') {
            steps {
                sh '''
                echo "Running Trivy vulnerability scan..."
                trivy image --severity HIGH,CRITICAL --exit-code 1 trivy-demo-app:latest
                '''
            }
        }

        stage('Push to Registry') {
            when {
                expression { currentBuild.result == null }
            }
            steps {
                sh '''
                echo "No HIGH or CRITICAL vulnerabilities found — pushing image"
                docker tag trivy-demo-app:latest my-registry/trivy-demo-app:latest
                # docker push my-registry/trivy-demo-app:latest
                '''
            }
        }
    }

    post {
        failure {
            echo "Build failed due to HIGH/CRITICAL vulnerabilities."
        }
        success {
            echo "Build completed and secure image pushed to registry."
        }
    }
}
✅ 4. Expected Behavior
🔴 If HIGH/CRITICAL Vulnerabilities Found

Jenkins build FAILS:

CRITICAL: CVE-2021-1234 in openssl
HIGH: CVE-2020-5678 in python-requests
Build step 'Execute shell' marked build as failure

🟢 If no major vulnerabilities

Build continues and image is pushed.

✅ 5. Exporting Trivy Reports
trivy image --format json --output report.json trivy-demo-app:latest


Use this for:

Audit

Dashboards

Security compliance

🎉 Summary

In Day2 you implemented:

Docker build security

Trivy scanning enforcement

CI/CD security gates

Automatic failure for vulnerable images

Secure artifact promotion into registries

This is a fundamental DevSecOps CI pipeline integration.
