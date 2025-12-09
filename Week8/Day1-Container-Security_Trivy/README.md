README.md — Week8-Day1: Container Security with Trivy
# Week 8 – Day 1  
# Container Security Scanning with Trivy  
Author: Sree  
VM: Vagrant Ubuntu 22.04 (devops-e2e-vm)

---

## 📌 Overview
Today you learned how to:
- Install Trivy
- Scan local Docker images
- Scan images stored in ECR
- Understand vulnerability severity and CVE results
- Scan filesystem, directories, and Kubernetes workloads

This README is a single consolidated file for OneNote.

---

## ✅ 1. Verify Trivy Installation

```bash
trivy --version


Expected output (version may vary):

Version: 0.68.1

✅ 2. List Available Docker Images
docker images


Example output:

week5-flask-app    latest   a48d0f6c8a10
953816747017.dkr.ecr.us-east-1.amazonaws.com/week5-flask-app  v1
python 3.10-slim

✅ 3. Scan a Local Docker Image

⚠️ Important: Your earlier error was because of a typo (laatest).
Correct command:

trivy image week5-flask-app:latest


OR simply:

trivy image week5-flask-app

📝 Example Trivy Scan Output

(Will show CVEs, severity levels, affected packages, fixed versions)

Total: 23 (HIGH: 3, MEDIUM: 10, LOW: 10)


Interpreting this:

HIGH / CRITICAL → Important for interviews

MEDIUM / LOW → Generally acceptable for labs

Python slim/base images often show openssl/zlib vulnerabilities

✅ 4. Scan the ECR Image

First log in to ECR:

aws ecr get-login-password --region us-east-1 \
 | docker login --username AWS --password-stdin 953816747017.dkr.ecr.us-east-1.amazonaws.com


Then scan:

trivy image 953816747017.dkr.ecr.us-east-1.amazonaws.com/week5-flask-app:v1

✅ 5. Scan Image by IMAGE ID
trivy image a48d0f6c8a10


Useful when tag names are confusing.

✅ 6. Scan a Directory (Source Code Scan)
trivy fs .


This checks:

Hardcoded secrets

Vulnerable dependencies

Misconfigurations

✅ 7. Scan a Kubernetes Running Pod (K8s Cluster Scan)
trivy k8s --report summary


OR scan a specific pod:

trivy k8s pod flaskapp-flask-app-xxxx -n week6

✅ 8. Scan SBOM (Software Bill of Materials)

Generate SBOM:

trivy image --format cyclonedx --output sbom.json week5-flask-app:latest

🔍 Common Trivy Errors & Fixes
❌ Error: Image Not Found

Happens when tag is wrong:

unable to find the specified image


Fix: Check image name:

docker images

❌ Error: Remote (Docker Hub) Unauthorized

Trivy tries:

docker

containerd

podman

remote registry

If local image doesn’t exist → Trivy queries Docker Hub → returns UNAUTHORIZED.

Fix: Ensure correct image name/tag.

🎯 Interview Notes

Be prepared to explain:

Why scanning base images is important

Difference between OS vulnerabilities & application dependencies

Why python:slim reduces attack surface

What CVSS score is

How CI/CD integrates Trivy

Example CI command:

trivy image --exit-code 1 --severity HIGH,CRITICAL week5-flask-app:latest


This fails a pipeline if severe vulnerabilities exist.

✅ Summary

Today you completed:

Task	Status
Trivy install & version check	✅
Local image scan	✅
ECR image scan	✅
FS scan	✅
K8s workload scan	✅
SBOM generation	✅
You are now fully ready for container security interview questions and CI/CD integration with Trivy.
