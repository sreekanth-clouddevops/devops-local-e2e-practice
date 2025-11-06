# **Day2: Linux Permissions, Ownership & Process Management**

## 🎯 Objective

* Understand Linux user/group model
* Learn how to manage permissions and ownership
* Monitor and control processes
* Automate a simple process-check script
* Document commands and concepts for quick review

---

## 🧠 Concept Notes (Interview / Training Reference)

### 🔹 Users & Groups

| Command                      | Purpose                                  |
| ---------------------------- | ---------------------------------------- |
| `id`                         | Show UID, GID and groups of current user |
| `whoami`                     | Display current user                     |
| `adduser <name>`             | Add new user (interactive)               |
| `groupadd <name>`            | Create a group                           |
| `usermod -aG <group> <user>` | Add user to group                        |
| `su - <user>`                | Switch user                              |

### 🔹 Permissions Model

* Each file has **3 levels:** User (u), Group (g), Others (o)
* And **3 types:** Read (r = 4), Write (w = 2), Execute (x = 1)
* **Example:** `-rwxr-x---` → User: rwx, Group: r-x, Others: ---
* **Numeric Mode:** `chmod 750 file.sh` → u=rwx(7), g=rx(5), o=none(0)

### 🔹 Ownership Commands

| Command                     | Function           |
| --------------------------- | ------------------ |
| `ls -l`                     | Show owner & group |
| `chown <user>:<group> file` | Change ownership   |
| `chgrp <group> file`        | Change group only  |

### 🔹 Process Management

| Command            | Purpose                |
| ------------------ | ---------------------- |
| `ps -ef`           | List all processes     |
| `top / htop`       | Real-time monitor      |
| `kill <PID>`       | Stop process           |
| `sleep 300 &`      | Run in background      |
| `jobs`, `bg`, `fg` | Manage background jobs |

---

## 🧩 Environment Setup

**📍Where to run:** Inside your VM terminal

```bash
cd ~/devops-local-e2e-practice
mkdir -p Week1/Day2-Permissions-Processes/scripts
cd Week1/Day2-Permissions-Processes
touch README.md
```

Structure:

```
Week1/
 └── Day2-Permissions-Processes/
      ├── README.md
      └── scripts/
```

---

## 🧠 Task 1: Create Users & Groups

```bash
sudo adduser dev1
sudo adduser dev2
sudo groupadd devteam
sudo usermod -aG devteam dev1
sudo usermod -aG devteam dev2
```

**Verify:**

```bash
id dev1
id dev2
getent group devteam
```

✅ Sample:

```
dev1 : uid=1001(dev1) gid=1001(dev1) groups=1001(dev1),1003(devteam)
```

---

## 🧠 Task 2: File Permissions Practice

```bash
cd ~/devops-local-e2e-practice/Week1/Day2-Permissions-Processes
touch teamfile.txt
echo "Dev team file access" > teamfile.txt

sudo chown dev1:devteam teamfile.txt
sudo chmod 640 teamfile.txt  # rw-r----- 
ls -l teamfile.txt
```

✅ Expected:

```
-rw-r----- 1 dev1 devteam 20 Nov  9 10:35 teamfile.txt
```

---

## 🧠 Task 3: Permission Verification

Switch to dev2 and try to read:

```bash
su - dev2
cd ~/devops-local-e2e-practice/Week1/Day2-Permissions-Processes
cat teamfile.txt
exit
```

✅ Result: dev2 (can read) ✅; others (no access) 🚫

---

## ⚙️ Task 4: Process Monitoring & Killing

```bash
# Start background process
sleep 300 &

# Check PID
ps -ef | grep sleep

# Kill process
kill <PID>
```

✅ Output:

```
vagrant      1749    1720    0 10:50 pts/0     00:00:00 sleep 300
[1]+   Terminated sleep 300
```

---

## ⚙️ Task 5: Mini Automation – Process Checker Script

Create `check_process.sh` inside `scripts/`

```bash
cd ~/devops-local-e2e-practice/Week1/Day2-Permissions-Processes/scripts
vim check_process.sh
```

Paste:

```bash
#!/bin/bash
# Simple process checker script
# Usage: ./check_process.sh <process_name>

process=$1
if [ -z "$process" ]; then
  echo "Usage: $0 <process_name>"
  exit 1
fi

if ps -ef | grep -q "[${process:0:1}]${process:1}"; then
  echo "✅ Process '$process' is running."
else
  echo "⚠️ Process '$process' not found. Starting..."
  sudo systemctl start $process 2>/dev/null || echo "Manual start needed for '$process'"
fi
```

Make executable:

```bash
chmod +x check_process.sh
```

Test:

```bash
./check_process.sh sshd
```

✅ Expected:

```
✅ Process 'sshd' is running.
```

---

## 📘 Summary Table

| Concept      | Command                          | Purpose                         |
| ------------ | -------------------------------- | ------------------------------- |
| User Mgmt    | `adduser`, `usermod`, `groupadd` | Create and manage users/groups  |
| Permissions  | `chmod `, `chown `, `chgrp`      | Change access control           |
| Process Mgmt | `ps`, `top`, `kill`, `sleep`     | Monitor and terminate processes |
| Automation   | Bash script (check_process.sh)   | Automate process check          |

---

## 🪜 Git Workflow

**Run inside VM:**

```bash
cd ~/devops-local-e2e-practice
git add Week1/Day2-Permissions-Processes
git commit -m "Week1-Day2: Permissions, Ownership & Process Management completed"
git push origin feature/Week1
```

**Verify on GitHub:**
👉 [https://github.com/sreekanth-clouddevops/devops-local-e2e-practice/tree/feature/Week1/Week1/Day2-Permissions-Processes](https://github.com/sreekanth-clouddevops/devops-local-e2e-practice/tree/feature/Week1/Week1/Day2-Permissions-Processes)

---

## ✅ Outcome

* Practiced user & group administration
* Mastered file ownership and permission concepts
* Controlled and monitored processes via CLI
* Automated process check with a script
* Documented and pushed Day 2 to GitHub branch `feature/Week1`
