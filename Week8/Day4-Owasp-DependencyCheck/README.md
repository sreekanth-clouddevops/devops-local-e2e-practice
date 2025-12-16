Below is your ENTIRE README.md in one single block.

# Week8 – Day4: OWASP Dependency-Check (Software Composition Analysis – SCA)

## 📌 Overview
Today we focus on Software Composition Analysis (SCA) using **OWASP Dependency-Check**.  
SCA identifies vulnerabilities inside **third-party libraries** (Flask, Django, Requests, Log4j, etc.).  
This complements SAST (source-code analysis) and container scanning.

---

# ✅ 1. Install OWASP Dependency-Check (CLI)

```bash
cd ~/devops-local-e2e-practice/Week8
mkdir -p Day4-Owasp-DependencyCheck
cd Day4-Owasp-DependencyCheck

wget https://github.com/jeremylong/DependencyCheck/releases/download/v10.0.3/dependency-check-10.0.3-release.zip
unzip dependency-check-10.0.3-release.zip


OWASP CLI will be inside:

dependency-check/bin/dependency-check.sh

✅ 2. Create Sample Python App to Scan
mkdir python-demo
cat <<EOF > python-demo/requirements.txt
flask==1.1.1
requests==2.19.1
django==2.2
EOF


These versions are intentionally vulnerable for demo.

✅ 3. Run Dependency-Check Scanner Locally
dependency-check/bin/dependency-check.sh \
  --project "Day4 Python Demo App" \
  --scan ./python-demo \
  --format ALL \
  --out ./reports


Generated reports:

reports/dependency-check-report.html
reports/dependency-check-report.json
reports/dependency-check-report.xml


Open HTML:

xdg-open reports/dependency-check-report.html

✅ 4. Jenkins CICD Integration

Create Jenkinsfile:

pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('OWASP Dependency Check') {
            steps {
                sh """
                dependency-check/bin/dependency-check.sh \
                    --project 'Day4 Python App' \
                    --scan python-demo \
                    --format XML \
                    --out owasp-report
                """
            }
        }

        stage('Publish Report') {
            steps {
                publishHTML([allowMissing: false,
                    reportDir: 'owasp-report',
                    reportFiles: 'dependency-check-report.html',
                    reportName: 'OWASP Dependency Report'])
            }
        }
    }
}

✅ 5. Install Jenkins Plugin

Go to:

Manage Jenkins → Manage Plugins → Available
Search: "OWASP Dependency Check"
Install

✅ 6. Run Jenkins Pipeline

Pipeline Stages:

Checkout code

Run SCA scan

Publish OWASP report

You will see:

✔ Passed libraries

⚠ Medium vulnerabilities

❌ High/Critical vulnerabilities

Upgrade recommendations

📌 Why SCA Matters (Interview Points)
SAST vs SCA
Type	What it scans	Purpose
SAST	Your source code	Finds coding bugs
SCA	Third-party libraries	Finds CVEs in dependencies
Why dependency scanning is critical

Most modern apps contain 80–90% third-party code

Vulnerabilities like Log4j, OpenSSL, Django RCE, Requests SSRF come from dependencies

Faster remediation: update library version instead of rewriting code

Good talking point

"SCA prevents supply-chain attacks by finding CVEs inside open-source dependencies before deployment."
