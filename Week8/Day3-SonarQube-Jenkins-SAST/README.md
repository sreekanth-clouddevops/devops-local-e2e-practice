High-level steps (what to run where)
A. On the Vagrant VM – create Day3 folder & sample app
cd ~/devops-local-e2e-practice
mkdir -p Week8/Day3-SonarQube-Jenkins-SAST
cd Week8/Day3-SonarQube-Jenkins-SAST

cat > app.py << 'EOF'
def add(a, b):
    return a + b

def bad_function(x):
    # example of bad pattern just for sonar to flag (unused variable etc.)
    unused = 123
    if x == None:
        return 0
    return x * 2

if __name__ == "__main__":
    print(add(2, 3))
EOF

cat > sonar-project.properties << 'EOF'
sonar.projectKey=week8-day3-python-app
sonar.projectName=Week8-Day3 Python Demo App
sonar.projectVersion=1.0

sonar.sourceEncoding=UTF-8
sonar.sources=.
sonar.python.version=3
EOF


Add a Jenkinsfile (we’ll put full content in README below):

cat > Jenkinsfile << 'EOF'
pipeline {
  agent any

  environment {
    SCANNER_HOME = tool 'sonar-scanner'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
        sh 'ls -R'
      }
    }

    stage('SonarQube Analysis') {
      steps {
        dir('Week8/Day3-SonarQube-Jenkins-SAST') {
          withSonarQubeEnv('local-sonar') {
            sh """
              ${SCANNER_HOME}/bin/sonar-scanner \
                -Dsonar.projectKey=week8-day3-python-app \
                -Dsonar.sources=. \
                -Dsonar.python.version=3
            """
          }
        }
      }
    }

    stage('Quality Gate') {
      steps {
        timeout(time: 3, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
        }
      }
    }
  }
}
EOF


Push this to GitHub (from VM):

cd ~/devops-local-e2e-practice
git add Week8/Day3-SonarQube-Jenkins-SAST
git commit -m "Week8 Day3 - SonarQube + Jenkins SAST"
git push origin feature/Week8

B. On the Vagrant VM – run SonarQube in Docker
docker pull sonarqube:lts-community

docker run -d --name sonar \
  -p 9000:9000 \
  -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true \
  sonarqube:lts-community


Check:

docker ps | grep sonar


From Windows host, open:
👉 http://192.168.56.60:9000

Login: admin / admin

Force password change → set a new one (note it somewhere).

Create a token:

Top-right → your user → My Account → Security

Generate token: name jenkins-sonar-token

Copy the token (you see it only once).

C. In Jenkins – integrate SonarQube

Install plugins (if not already):

Manage Jenkins → Plugins → Available / Installed

Ensure:

SonarQube Scanner for Jenkins

Quality Gates (often bundled with sonar plugin or “Pipeline: Multibranch” etc. already there)

Add SonarQube server

Manage Jenkins → Configure System → SonarQube servers

Check “Enable injection of SonarQube server configuration…”

Add server:

Name: local-sonar

Server URL: http://localhost:9000

Server authentication token:

Add → “Secret Text” → paste jenkins-sonar-token → ID sonar-admin-token

Choose that credential and Save.

Configure Sonar Scanner tool

Manage Jenkins → Global Tool Configuration

Under SonarQube Scanner:

Name: sonar-scanner

Check “Install automatically”

Save.

Create Jenkins pipeline job

New Item → Name: week8-day3-sonar-sast

Type: Pipeline

Pipeline → Definition: Pipeline script from SCM

SCM: Git

Repo URL: your GitHub repo (https://github.com/.../devops-local-e2e-practice.git)

Credentials: your GitHub creds if needed

Script Path: Week8/Day3-SonarQube-Jenkins-SAST/Jenkinsfile

Save.

Run the pipeline

Build Now

Stages:

Checkout

SonarQube Analysis

Quality Gate

If Quality Gate passes → build = SUCCESS.

Go to SonarQube UI → Projects → you should see Week8-Day3 Python Demo App with issues, code smells, etc.
