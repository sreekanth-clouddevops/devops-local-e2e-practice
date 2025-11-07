# **Day3: Jenkins Pipeline (Declarative Jenkinsfile)**

## 🎯 Objectives

* Define a CI pipeline in code (`Jenkinsfile`)
* Run stages: checkout, build, test, package
* Archive artifacts and use post conditions
* Parameterize builds for different environments

---

## 🧠 Concept Notes (Interview / Training)

### Declarative vs Scripted

* **Declarative**: Opinionated, easier to read/maintain, uses `pipeline {}`.
* **Scripted**: Full Groovy; more flexible but verbose (`node { ... }`).

### Core Blocks

| Block         | Purpose                                          |
| ------------- | ------------------------------------------------ |
| `agent`       | Where the job runs (`any`, `label`, `docker`)    |
| `options`     | Job-level settings (timestamps, ANSI color)      |
| `parameters`  | Inputs at build time                             |
| `environment` | Key/value variables for all steps                |
| `stages`      | Ordered steps of the pipeline                    |
| `post`        | Always/success/failure notifications & archiving |

### Useful Directives

* `when` to conditionally run a stage
* `tools` to auto-install configured JDK/Maven/Node
* `parallel` to run stages concurrently
* `archiveArtifacts`, `junit`, `publishHTML` for outputs

---

## ⚙️ Folder & Files

```
Week2/
 └── Day3-Jenkins-Pipeline/
     ├── Jenkinsfile
     └── scripts/
         └── hello.sh
```

---

## 🧩 Jenkinsfile (Declarative)

```groovy
pipeline {
  agent any
  options {
    ansiColor('xterm')
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '10'))
  }
  parameters {
    string(name: 'TARGET_ENV', defaultValue: 'dev', description: 'Environment name')
    booleanParam(name: 'RUN_HEALTH_CHECK', defaultValue: true, description: 'Run health check step')
  }
  environment {
    PROJECT_NAME = 'devops-local-e2e-practice'
    REPORT_DIR   = 'Week2/Day3-Jenkins-Pipeline/reports'
  }
  stages {
    stage('Checkout') {
      steps {
        checkout scm
        sh 'mkdir -p $REPORT_DIR'
        sh 'echo "Commit: $(git rev-parse --short HEAD)" | tee $REPORT_DIR/build_info.txt'
      }
    }
    stage('Build') {
      steps {
        sh '''
          echo "===== BUILD STEP ====="
          echo "Env: ${TARGET_ENV}"
          echo "Host: $(hostname)"
          echo "Disk summary:"
          df -h | grep -v tmpfs
        '''
      }
    }
    stage('Unit Tests (Demo)') {
      steps {
        sh '''
          echo "===== TEST STEP ====="
          echo "Pretend tests running..."
          sleep 1
          echo "All green!" | tee $REPORT_DIR/test_summary.txt
        '''
      }
    }
    stage('Health Check') {
      when { expression { return params.RUN_HEALTH_CHECK } }
      steps {
        sh '''
          echo "===== HEALTH CHECK ====="
          uptime | tee $REPORT_DIR/health.txt
        '''
      }
    }
    stage('Package Artifact') {
      steps {
        sh '''
          echo "===== PACKAGE ====="
          tar -czf $REPORT_DIR/artifacts_${TARGET_ENV}.tgz $REPORT_DIR/*.txt || true
        '''
      }
    }
  }
  post {
    always {
      archiveArtifacts artifacts: 'Week2/Day3-Jenkins-Pipeline/reports/**', fingerprint: true
      echo "Pipeline finished (result: ${currentBuild.currentResult})"
    }
    success { echo 'Build succeeded ✅' }
    failure { echo 'Build failed ❌' }
  }
}
```

---

## 🔧 Create Pipeline Job (Jenkins UI)

* **New Item → Pipeline**
* **Definition:** Pipeline script from SCM
* **SCM Git URL:** `https://github.com/sreekanth-clouddevops/devops-local-e2e-practice.git`
* **Branch:** `feature/Week2`
* **Script Path:** `Week2/Day3-Jenkins-Pipeline/Jenkinsfile`
* **Trigger:** Poll SCM `H/5 * * * *` or **GitHub hook**.

---

## ✅ Validation

* Console shows all stages with timestamps & color
* Artifacts archived under **Build → Artifacts**
* Parameters visible in **Build with Parameters**

---

## 🧾 Quick Q&A

* **Where are Jenkins workspace files?**
  `/var/lib/jenkins/workspace/<job-name>`
* **How to pass parameters into shell steps?**
  Use `${PARAM_NAME}` or `$PARAM_NAME` inside `sh` block.
* **How to reuse code across pipelines?**
  Jenkins **Shared Libraries** (define `vars/` & `src/` in a separate Git repo).

---

## Outcome

* Pipeline-as-Code implemented and executed
* Parameterized, environment-aware, and artifact-producing pipeline
* Ready for Day4 to integrate Docker build & push
