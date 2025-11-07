# **Day2: Jenkins Freestyle Jobs + Build Triggers**

## 🎯 Objectives

* Create a Freestyle Jenkins job
* Integrate with GitHub repository
* Run custom build shell scripts
* Configure automatic triggers and archive artifacts

---

## 🧠 Concept Notes (Interview / Training Reference)

### 🔹 Jenkins Job Types

| Type              | Description                                 |
| ----------------- | ------------------------------------------- |
| **Freestyle**     | GUI-based job configuration, easy to set up |
| **Pipeline**      | Code-based (Jenkinsfile) — ideal for CI/CD  |
| **Multibranch**   | Auto-discovers branches & Jenkinsfiles      |
| **Folder/Matrix** | Organizes or executes parallel builds       |

### 🔹 Build Triggers

| Trigger Type           | Purpose                                |
| ---------------------- | -------------------------------------- |
| **Poll SCM**           | Jenkins checks Git repo periodically   |
| **GitHub Webhook**     | GitHub notifies Jenkins on push        |
| **Build periodically** | Cron-based time schedule               |
| **Upstream project**   | Trigger job after another job finishes |

---

## ⚙️ Setup Steps

### 1️⃣ Create Job

* **Dashboard → New Item → Freestyle Project**
* Name: `Week2-Day2-Freestyle-Build`

### 2️⃣ Configure Source Code

```
Repository URL: https://github.com/sreekanth-clouddevops/devops-local-e2e-practice.git
Branch: feature/Week2
```

### 3️⃣ Add Build Step

```
Execute Shell:
#!/bin/bash
cd Week2/Day2-Jenkins-Freestyle-Job/scripts
./build.sh
```

### 4️⃣ Add Triggers

**Poll SCM:**

```
H/5 * * * *
```

**OR**
**GitHub Hook Trigger for GITScm Polling**

---

## 🧩 Example Build Script

```bash
#!/bin/bash
set -euo pipefail
echo "=============================="
echo "Starting Jenkins Build Job"
echo "=============================="
echo "Build triggered at: $(date)"
echo "Running on host: $(hostname)"
echo
echo "Checking Disk and Memory Status:"
df -h | grep -v tmpfs
echo
free -m
echo
echo "Build step completed successfully!"
echo "=============================="
```

---

## 🧩 Post-Build Actions

* Archive artifacts:

  ```
  Week2/Day2-Jenkins-Freestyle-Job/scripts/build.sh
  ```
* Optional: Email notification for build result.

---

## 🧩 Validation

* ✅ GitHub repo cloned successfully
* ✅ Build executes shell script
* ✅ Job triggered automatically (via webhook or polling)
* ✅ Artifacts archived under build history

---

## 🧾 Interview Quick Notes

| Question                                                | Answer                                                                |
| ------------------------------------------------------- | --------------------------------------------------------------------- |
| **What’s the difference between Poll SCM and Webhook?** | Poll SCM checks periodically; Webhook triggers instantly from GitHub. |
| **Where does Jenkins store workspace?**                 | `/var/lib/jenkins/workspace/<job_name>`                               |
| **How to pass parameters to a job?**                    | Enable “This project is parameterized” and define parameters.         |
| **Can Freestyle Jobs run shell or Python scripts?**     | Yes, via “Execute Shell” or “Execute Windows Batch Command.”          |
| **Where are job configs stored?**                       | `/var/lib/jenkins/jobs/<job_name>/config.xml`                         |

---

## 🧩 Outcome

* Jenkins Freestyle job successfully integrated with GitHub
* Auto-trigger configured for SCM updates
* Build executed shell script and archived artifacts
* Ready to move toward **Pipeline-as-Code (Jenkinsfile)** in Day3

---

**Next:**
➡️ **Day3: Jenkins Pipeline – Declarative Jenkinsfile (Build, Test, Archive)**
We’ll move to writing Jenkins pipelines in YAML-like DSL for full automation.
