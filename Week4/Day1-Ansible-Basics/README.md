# Week 4 – Day 1: Ansible Basics (Localhost Inventory + First Playbook)

## 🎯 Objectives

- Install and verify **Ansible** on Ubuntu VM
- Create a simple **inventory** targeting localhost
- Run **ad-hoc Ansible commands** (ping, uptime, df -h, etc.)
- Write and run a **basic playbook**:
  - Update apt cache
  - Install packages
  - Create a directory
  - Deploy `/etc/motd` from a Jinja2 template
- Track everything in Git under `Week4/Day1-Ansible-Basics`

---

## 🧠 Concept Notes (Interview / Training)

### What is Ansible?

- An **agentless** configuration management and automation tool
- Uses **SSH** to connect to Linux hosts
- Playbooks written in **YAML**
- Manages:
  - Packages
  - Files
  - Services
  - Users
  - Cloud resources (AWS, Azure, etc.)

### Key concepts

- **Inventory**: List of managed hosts (INI, YAML, or dynamic)
- **Module**: Unit of work (e.g., `apt`, `file`, `template`, `service`, `user`)
- **Task**: A single module call with parameters
- **Play**: Mapping between hosts and tasks
- **Playbook**: YAML file containing one or more plays

### Ad-hoc vs Playbook

- **Ad-hoc**: one-off commands:  
  `ansible -i hosts.ini local -m command -a "uptime"`
- **Playbook**: reusable automation in YAML:  
  `ansible-playbook -i hosts.ini playbooks/site.yml`

---

## 📁 Folder Structure

```text
Week4/
└── Day1-Ansible-Basics/
    ├── inventory/
    │   └── hosts.ini
    ├── playbooks/
    │   └── site.yml
    ├── files/
    │   └── motd.j2
    ├── logs/
    │   └── day1-run.log
    └── README.md
```

---

## 1️⃣ Install Ansible

On the Ubuntu VM:

```bash
sudo apt-get update -y
sudo apt-get install -y ansible

ansible --version
```

You should see Ansible version and Python details.

---

## 2️⃣ Create Local Inventory

Create directory and file:

```bash
cd ~/devops-local-e2e-practice
mkdir -p Week4/Day1-Ansible-Basics/inventory
cd Week4/Day1-Ansible-Basics/inventory

cat > hosts.ini << 'EOF'
[local]
localhost ansible_connection=local
EOF
```

Check:

```bash
cat hosts.ini
```

---

## 3️⃣ Run Ad-Hoc Commands

From Day1 root folder:

```bash
cd ~/devops-local-e2e-practice/Week4/Day1-Ansible-Basics
```

### 3.1 Ping

```bash
ansible -i inventory/hosts.ini local -m ping
```

Expected result:

```text
localhost | SUCCESS => {
  "changed": false,
  "ping": "pong"
}
```

### 3.2 Uptime

```bash
ansible -i inventory/hosts.ini local -m command -a "uptime"
```

### 3.3 Disk usage

```bash
ansible -i inventory/hosts.ini local -m shell -a "df -h"
```

### 3.4 Create test file

```bash
ansible -i inventory/hosts.ini local -m file -a "path=/tmp/ansible-demo.txt state=touch"

ls -l /tmp/ansible-demo.txt
```

---

## 4️⃣ Template for MOTD (files/motd.j2)

Create template file:

```bash
cd ~/devops-local-e2e-practice/Week4/Day1-Ansible-Basics/files

cat > motd.j2 << 'EOF'
Welcome to {{ inventory_hostname }} - Managed by Ansible

Environment: {{ env_name | default('dev') }}
Date: {{ ansible_date_time.date }}  Time: {{ ansible_date_time.time }}

Have a great DevOps practice session, Sree!
EOF
```

---

## 5️⃣ Playbook (playbooks/site.yml)

Create playbook:

```bash
cd ~/devops-local-e2e-practice/Week4/Day1-Ansible-Basics/playbooks

cat > site.yml << 'EOF'
---
- name: Week4 Day1 - Ansible Basics on local VM
  hosts: local
  become: true
  vars:
    env_name: "local-dev"

  tasks:
    - name: Update apt cache
      ansible.builtin.apt:
        update_cache: yes
        cache_valid_time: 3600

    - name: Install basic packages
      ansible.builtin.apt:
        name:
          - htop
          - tree
        state: present

    - name: Create DevOps practice directory
      ansible.builtin.file:
        path: /opt/devops-labs
        state: directory
        owner: "{{ ansible_user | default('vagrant') }}"
        group: "{{ ansible_user | default('vagrant') }}"
        mode: '0755'

    - name: Deploy custom MOTD banner
      ansible.builtin.template:
        src: ../files/motd.j2
        dest: /etc/motd
        owner: root
        group: root
        mode: '0644'

    - name: Show completion message
      ansible.builtin.debug:
        msg: "Week4 Day1 basic Ansible setup completed on {{ inventory_hostname }}"
EOF
```

---

## 6️⃣ Run the Playbook

From Day1 root:

```bash
cd ~/devops-local-e2e-practice/Week4/Day1-Ansible-Basics

ansible-playbook -i inventory/hosts.ini playbooks/site.yml | tee logs/day1-run.log
```

Verify:

```bash
ls -ld /opt/devops-labs
cat /etc/motd
htop --version
tree --version
```

---

## 7️⃣ Git Commands

From repository root:

```bash
cd ~/devops-local-e2e-practice

git add Week4/Day1-Ansible-Basics
git commit -m "Week4-Day1: Ansible basics with localhost inventory and playbook"
git push origin feature/Week4
```

(Or push to your current feature branch.)

---

## 🧾 Quick Summary Commands

### Inventory + Ad-hoc

```bash
cd ~/devops-local-e2e-practice/Week4/Day1-Ansible-Basics

ansible -i inventory/hosts.ini local -m ping
ansible -i inventory/hosts.ini local -m command -a "uptime"
ansible -i inventory/hosts.ini local -m shell -a "df -h"
ansible -i inventory/hosts.ini local -m file -a "path=/tmp/ansible-demo.txt state=touch"
```

### Playbook

```bash
ansible-playbook -i inventory/hosts.ini playbooks/site.yml | tee logs/day1-run.log
```

### Git

```bash
cd ~/devops-local-e2e-practice
git add Week4/Day1-Ansible-Basics
git commit -m "Week4-Day1: Ansible basics with localhost inventory and playbook"
git push origin feature/Week4
```

---

## ✅ Outcome

By the end of **Week 4 – Day 1**:

- Ansible is installed and working on your VM
- You have a **local inventory** targeting `localhost`
- You can run **ad-hoc Ansible commands**
- You built and executed a **basic Ansible playbook**
- You understand the core concepts: inventory, modules, tasks, play, playbook

You are now ready for **Week4 – Day2: Ansible roles, handlers, and templates for a simple web server**.

