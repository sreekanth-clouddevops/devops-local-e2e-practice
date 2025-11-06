# **Day5: Shell Scripting & System Health Report Project**

## 🎯 Objectives

* Strengthen Bash scripting fundamentals
* Automate system information collection
* Combine Day1–Day4 Linux & Git knowledge
* Produce a reusable System Health Report script
* Prepare notes for scripting interview questions

---

## 🧠 Concept Notes (Interview / Training Reference)

### 🔹 Shell Scripting Essentials

| Concept             | Explanation                     | Example                                |
| ------------------- | ------------------------------- | -------------------------------------- |
| **Variable**        | Stores reusable data            | `NAME="Sree"` → `echo $NAME`           |
| **Positional Args** | Script inputs                   | `$0`, `$1`, `$2`                       |
| **Conditional**     | Executes logic                  | `if [ -f file ]; then echo exists; fi` |
| **Loop**            | Repeats actions                 | `for i in 1 2 3; do echo $i; done`     |
| **Exit Codes**      | 0 = success, non-zero = failure | `echo $?`                              |
| **Functions**       | Reusable code blocks            | `myfunc(){ echo hi; }`                 |

### 🔹 Redirection

| Symbol | Purpose           |                                |
| ------ | ----------------- | ------------------------------ |
| `>`    | Overwrite         |                                |
| `>>`   | Append            |                                |
| `<`    | Input redirection |                                |
| `      | `                 | Pipe output to another command |

### 🔹 Scripting Best Practices

* Use `#!/bin/bash` at top
* Add comments for readability
* Validate inputs before using them
* Make scripts executable: `chmod +x script.sh`
* Use `set -euo pipefail` for strict error handling

---

## ⚙️ Environment Setup

**📍 Where to Run:** Inside Ubuntu VM

```bash
cd ~/devops-local-e2e-practice
mkdir -p Week1/Day5-Shell-Scripting-Project/scripts
cd Week1/Day5-Shell-Scripting-Project
touch README.md
```

---

## 🧩 Task 1: Create System Health Script

```bash
cd ~/devops-local-e2e-practice/Week1/Day5-Shell-Scripting-Project/scripts
vim system_health_report.sh
```

Paste:

```bash
#!/bin/bash
# ================================================
# Script Name : system_health_report.sh
# Purpose     : Generate system health summary
# Author      : Sreekanth CloudDevOps
# ================================================

DATE=$(date '+%Y-%m-%d_%H-%M-%S')
HOST=$(hostname)
OUTPUT="/tmp/system_report_${HOST}_${DATE}.log"

echo "===================================" > $OUTPUT
echo "      SYSTEM HEALTH REPORT" >> $OUTPUT
echo "Generated on: $(date)" >> $OUTPUT
echo "===================================" >> $OUTPUT
echo "" >> $OUTPUT

# Host and uptime
echo "Hostname       : $HOST" >> $OUTPUT
echo "Uptime         : $(uptime -p)" >> $OUTPUT

# Disk usage
echo "" >> $OUTPUT
echo "----- Disk Usage -----" >> $OUTPUT
df -h >> $OUTPUT

# Memory usage
echo "" >> $OUTPUT
echo "----- Memory Usage -----" >> $OUTPUT
free -m >> $OUTPUT

# Top 5 CPU-consuming processes
echo "" >> $OUTPUT
echo "----- Top 5 Processes by CPU -----" >> $OUTPUT
ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -6 >> $OUTPUT

# Network check
echo "" >> $OUTPUT
echo "----- Network Interfaces -----" >> $OUTPUT
ip -br addr >> $OUTPUT

# Load average
echo "" >> $OUTPUT
LOAD=$(uptime | awk -F'load average:' '{ print $2 }')
echo "Load Average   : $LOAD" >> $OUTPUT

# Service status check (optional argument)
SERVICE=$1
if [ -n "$SERVICE" ]; then
    echo "" >> $OUTPUT
    echo "----- Service Status Check: $SERVICE -----" >> $OUTPUT
    systemctl status $SERVICE | grep Active >> $OUTPUT 2>/dev/null || echo "Service not found or permission denied" >> $OUTPUT
fi

echo "" >> $OUTPUT
echo "Report saved at: $OUTPUT"
```

---

## 🧩 Task 2: Make Executable and Run

```bash
chmod +x system_health_report.sh
./system_health_report.sh
./system_health_report.sh ssh
```

✅ Output sample:

```
Report saved at: /tmp/system_report_devops-e2e-vm_2025-11-10_15-12-45.log
```

---

## 🧩 Task 3: View Report

```bash
cat /tmp/system_report_*.log | less
```

✅ Sample sections:

```
SYSTEM HEALTH REPORT
Hostname : devops-e2e-vm
Uptime   : up 1 hour, 22 minutes
----- Disk Usage -----
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        64G  4.5G   60G   7% /
----- Memory Usage -----
Mem: 3936 950 1200 700 1100 3000
----- Top 5 Processes -----
PID COMMAND %CPU %MEM
132 sshd    0.3 0.1
...
```

---

## 🧩 Task 4: Copy and Commit to GitHub

```bash
cp /tmp/system_report_*.log ~/devops-local-e2e-practice/Week1/Day5-Shell-Scripting-Project/
cd ~/devops-local-e2e-practice
git add Week1/Day5-Shell-Scripting-Project
git commit -m "Week1-Day5: Added System Health Report Script"
git push origin feature/Week1
```

---

## 🧩 Task 5: Optional Enhancements

* Email report if CPU > 80%
* Archive logs older than 7 days:

  ```bash
  find /tmp -name "system_report_*" -mtime +7 -delete
  ```
* Automate with `cron`:

  ```bash
  crontab -e
  */30 * * * * /home/vagrant/devops-local-e2e-practice/Week1/Day5-Shell-Scripting-Project/scripts/system_health_report.sh
  ```

  #*/5 * * * * /home/vagrant/devops-local-e2e-practice/Week1/Day5-Shell-Scripting-Project/scripts/system_health_report.sh ssh >> /home/vagrant/system-health-logs/cron.log 2>&1


---

## 🧾 Interview Notes (Shell Scripting Section)

| Question                                | Quick Answer                                                         |
| --------------------------------------- | -------------------------------------------------------------------- |
| **How do you debug shell scripts?**     | Add `set -x` at top to trace execution                               |
| **What does `$?` mean?**                | Exit code of last command (0=success)                                |
| **How do you read user input?**         | `read varname`                                                       |
| **What is a here document?**            | `cat <<EOF ... EOF` used to write multi-line text                    |
| **Difference between `sh` and `bash`?** | `bash` = enhanced Bourne shell with features like arrays & functions |
| **What is crontab used for?**           | Schedule jobs automatically                                          |
| **How do you make a script portable?**  | Use `#!/bin/bash`, no hardcoded paths, handle errors                 |

---

## 🧩 Outcome

* Created a professional-grade system health automation script
* Practiced variables, loops, and conditionals
* Generated log files dynamically
* Learned how to schedule scripts for continuous monitoring
* Pushed all work to `feature/Week1` branch

---

**Next:**
➡️ Start **Week2: Jenkins CI/CD Fundamentals + Job Creation + Pipeline Concepts**
We’ll move from scripting to automation pipelines using Jenkins (Week2–Day1 onwards).
