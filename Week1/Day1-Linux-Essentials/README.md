# **Day1: Linux Essentials & File Operations**

## 🎯 **Objective**

* Learn Linux basics: navigation, files, and directories
* Practice file creation, copying, and redirection
* Collect system and process information
* Document the workflow and push to GitHub

---

## 🧩 **Environment Setup**

**Where to Run:** Inside your Ubuntu VM (via MobaXterm or VSCode Remote SSH)

```bash
cd ~/devops-local-e2e-practice
mkdir -p Week1/Day1-Linux-Essentials/tasks
cd Week1/Day1-Linux-Essentials
touch README.md
```

Final structure:

```
devops-local-e2e-practice/
└── Week1/
    └── Day1-Linux-Essentials/
        ├── README.md
        └── tasks/
```

---

## 🧠 **Task 1: System Information**

**Goal:** Gather system and user information into a report file.

**Commands (Run inside VM):**

```bash
cd ~/devops-local-e2e-practice/Week1/Day1-Linux-Essentials/tasks

echo "### System Information Report" > system_info.txt
echo "Generated on: $(date)" >> system_info.txt
echo "---------------------------------" >> system_info.txt

echo "Hostname: $(hostname)" >> system_info.txt
lsb_release -d | awk -F'\t' '{print "OS:", $2}' >> system_info.txt
echo "Kernel: $(uname -r)" >> system_info.txt
echo "Architecture: $(uname -m)" >> system_info.txt
echo "Logged in User: $(whoami)" >> system_info.txt
echo "Current Directory: $(pwd)" >> system_info.txt
```

**Verify Output:**

```bash
cat system_info.txt
```

✅ **Sample Output:**

```
### System Information Report
Generated on: Fri Nov  8 12:35:10 IST 2025
---------------------------------
Hostname: devops-e2e-vm
OS: Ubuntu 22.04.5 LTS
Kernel: 5.15.0-160-generic
Architecture: x86_64
Logged in User: vagrant
Current Directory: /home/vagrant/devops-local-e2e-practice/Week1/Day1-Linux-Essentials/tasks
```

---

## 📂 **Task 2: File Operations**

**Goal:** Practice creating, modifying, copying, and moving files.

**Commands (Run inside VM):**

```bash
cd ~/devops-local-e2e-practice/Week1/Day1-Linux-Essentials/tasks

# Create files
touch file1.txt file2.txt

# Write and append
echo "This is file1 content." > file1.txt
echo "Adding one more line to file1." >> file1.txt

# Copy and move
cp file1.txt copy_file.txt
mv file2.txt moved_file.txt

# Display
cat copy_file.txt
head -n 1 copy_file.txt
tail -n 1 copy_file.txt
```

✅ **Sample Output:**

```
This is file1 content.
Adding one more line to file1.
```

**Learnings:**

* `>` overwrites file contents
* `>>` appends data
* `mv` moves or renames files
* `cp` duplicates files

---

## 📁 **Task 3: Directory Navigation**

**Goal:** Explore file system navigation and searching.

**Commands (Run inside VM):**

```bash
cd ~/devops-local-e2e-practice/Week1/Day1-Linux-Essentials
pwd
ls -lh
find ~/devops-local-e2e-practice -name "*.txt"
```

✅ **Expected Output Example:**

```
/home/vagrant/devops-local-e2e-practice/Week1/Day1-Linux-Essentials
-rw-r--r-- 1 vagrant vagrant 1.1K Nov 8 12:45 system_info.txt
...
/home/vagrant/devops-local-e2e-practice/Week1/Day1-Linux-Essentials/tasks/file1.txt
```

---

## ⚙️ **Task 4: System Monitoring**

**Goal:** Learn how to check disk, memory, uptime, and processes.

**Commands (Run inside VM):**

```bash
cd ~/devops-local-e2e-practice/Week1/Day1-Linux-Essentials/tasks

df -h > system_state.txt
free -m >> system_state.txt
uptime >> system_state.txt
ps -ef | head -10 >> system_state.txt
```

✅ **Verify:**

```bash
cat system_state.txt
```

✅ **Sample Snippet:**

```
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        64G  4.5G   60G   7% /
Mem:            3936         950         1200         700         1100         3000
12:47:52 up  1:25,  2 users,  load average: 0.00, 0.01, 0.02
UID          PID    PPID  C STIME TTY          TIME CMD
root           1       0  0 11:21 ?        00:00:04 /sbin/init
```

---

## 🧾 **Summary**

| Command       | Description                     |
| ------------- | ------------------------------- |
| `pwd`         | Shows current directory         |
| `ls -lh`      | Lists files with readable sizes |
| `find <path>` | Searches files                  |
| `df -h`       | Disk usage overview             |
| `free -m`     | Memory details                  |
| `uptime`      | System load info                |
| `ps -ef`      | Process list                    |
| `>` / `>>`    | Redirect or append output       |

---

## 🪜 **Git Workflow**

**Commands (Run inside VM):**

```bash
cd ~/devops-local-e2e-practice
git add Week1/Day1-Linux-Essentials
git commit -m "Week1-Day1: Linux Essentials & File Operations completed"
git push origin feature/Week1
```

**Verify on GitHub:**
👉 [https://github.com/sreekanth-clouddevops/devops-local-e2e-practice/tree/feature/Week1/Week1/Day1-Linux-Essentials](https://github.com/sreekanth-clouddevops/devops-local-e2e-practice/tree/feature/Week1/Week1/Day1-Linux-Essentials)

---

## ✅ **Outcome**

* Practiced Linux commands for file & system operations
* Generated `system_info.txt` and `system_state.txt`
* Organized work under `Week1/Day1-Linux-Essentials`
* Successfully committed and pushed to GitHub branch `feature/Week1`

---

**Next:** Proceed to **Week1 – Day2: Linux Permissions, Ownership & Process Management**
