# **Day1: Jenkins Setup & UI Overview**

## 🎯 Objectives

* Install and run Jenkins in Docker
* Access Jenkins UI and configure admin user
* Install key plugins for CI/CD
* Understand Jenkins architecture & terminology

---

## 🧠 Concept Notes (Interview / Training Reference)

### 🔹 Jenkins Architecture

* **Controller (Master):** Manages jobs, schedules builds.
* **Agent (Node):** Executes builds; can be local or remote.
* **Executor:** Slot on agent that runs a job.

### 🔹 Jenkins Components

| Component         | Description                                                 |
| ----------------- | ----------------------------------------------------------- |
| **Job / Project** | Unit of work Jenkins executes (freestyle, pipeline, etc.)   |
| **Workspace**     | Directory where job runs                                    |
| **Build**         | Execution instance of a job                                 |
| **Artifact**      | Output generated (e.g., WAR, Docker image)                  |
| **Plugin**        | Extends Jenkins functionality                               |
| **Pipeline**      | Scripted or declarative job defined as code (`Jenkinsfile`) |

---

## ⚙️ Installation (Docker Method)

**📍 Run inside Ubuntu VM:**

```bash
sudo apt-get update -y
sudo apt-get install -y docker.io
sudo systemctl enable --now docker
sudo usermod -aG docker vagrant
newgrp docker
```

**Run Jenkins container:**

```bash
docker run -d \
  --name jenkins \
  -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts
```

---
## 🧩 Access Jenkins

Browser → `http://192.168.56.60:8080`

**Run Jenkins in VM:**

```bash
Install Jenkins on Ubuntu (inside your Vagrant VM)
        Run these commands one by one:
            sudo apt update -y
            sudo apt install openjdk-17-jdk -y
            
            # Add Jenkins repository and key
            curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
              /usr/share/keyrings/jenkins-keyring.asc > /dev/null
            
            echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
              https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
              /etc/apt/sources.list.d/jenkins.list > /dev/null
            
            # Install Jenkins
            sudo apt update -y
            sudo apt install jenkins -y
            
            # Enable & start
            sudo systemctl enable jenkins
            sudo systemctl start jenkins
            sudo systemctl status jenkins
```

## 🧩 Access Jenkins

Browser → `http://192.168.56.60:8080`

## 🧩 Access Jenkins  Open Jenkins Web UI
        In your host browser (Windows), open:
            👉 http://localhost:8080
                If it doesn’t open directly, confirm port 8080 is forwarded in your Vagrantfile:
                    config.vm.network "forwarded_port", guest: 8080, host: 8080
                Then restart:
vagrant reload


Unlock password:

```bash
docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

---

## 🧩 Initial Configuration

* **Install Suggested Plugins**
* **Create Admin User**
* **Confirm URL:** `http://192.168.56.60:8080`

---

## 🧩 Useful Plugins

| Plugin               | Purpose                          |
| -------------------- | -------------------------------- |
| Git                  | Integrate with GitHub repos      |
| Blue Ocean           | Modern UI for Pipelines          |
| Docker Pipeline      | Build Docker images in pipelines |
| Pipeline: Stage View | Visual pipeline stages           |
| AnsiColor            | Colorized console output         |
| Email Extension      | Send build status emails         |


![alt text](image.png)

---


## 🧩 Jenkins CLI Check

```bash
docker exec -it jenkins bash
jenkins-plugin-cli --list
```

---

## 🧾 Interview Quick Notes

| Question                                 | Answer                                                         |
| ---------------------------------------- | -------------------------------------------------------------- |
| **What is Jenkins?**                     | CI/CD tool to automate build, test, deploy.                    |
| **What are Jenkins pipelines?**          | Jobs defined as code in a `Jenkinsfile`.                       |
| **Freestyle vs Pipeline job?**           | Freestyle = UI-configured; Pipeline = code-based (repeatable). |
| **Where are Jenkins configs stored?**    | Inside `/var/jenkins_home` (volume).                           |
| **How does Jenkins integrate with Git?** | Using Git plugin; pulls code from GitHub to build/test.        |
| **What port does Jenkins use?**          | 8080 (web UI), 50000 (for agents).                             |

---

## 🧩 Troubleshooting

| Issue                      | Fix                                                |
| -------------------------- | -------------------------------------------------- |
| Port 8080 busy             | `docker stop <container>` using that port          |
| Can’t access URL           | Check VM IP / firewall (`sudo ufw allow 8080/tcp`) |
| Plugin install stuck       | Restart Jenkins container                          |
| Permission denied (Docker) | Add user to `docker` group                         |

---

## 🧩 Outcome

* Jenkins up and accessible from host
* Admin account & essential plugins configured
* Ready for pipeline and job creation

---

**Next:**
➡️ **Day 2: Jenkins Freestyle Jobs + Build Triggers (Integrate Git & Shell Builds)**
You’ll create your first real CI job that pulls from your GitHub repo and runs a build script.
