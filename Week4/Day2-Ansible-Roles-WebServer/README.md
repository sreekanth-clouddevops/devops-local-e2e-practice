# Week 4 – Day 2: Ansible Roles + Nginx Web Server (Localhost)

## 🎯 Objectives

- Understand **Ansible roles** and their directory structure  
- Create a reusable **`webserver` role**  
- Use the role to:
  - Install **Nginx**
  - Deploy a custom HTML page using a **Jinja2 template**
  - Ensure Nginx service is enabled and running  
- Access the web page using your Vagrant VM IP  
- Store everything under `Week4/Day2-Ansible-Roles-WebServer`

---

# 🧠 Concept Notes (Interview / Training)

### ❓ What is an Ansible Role?

A **role** is a structured way to organize Ansible automation.  
It splits logic into folders:

- `tasks/` – steps to execute  
- `handlers/` – restart/reload/service triggers  
- `templates/` – Jinja2 template files for dynamic content  
- `files/` – static files  
- `defaults/` – default variable definitions  
- `vars/` – higher-priority variables  

**Why roles?**

- Reusable  
- Clean structure  
- Easy to maintain  
- Mandatory in real DevOps projects  
- Perfect answer for interviews

---

## 📁 Final Folder Structure (Corrected Version)

```
Week4/
└── Day2-Ansible-Roles-WebServer/
    ├── inventory/
    │   └── hosts.ini
    ├── playbooks/
    │   ├── site.yml
    │   └── roles/
    │       └── webserver/
    │           ├── defaults/
    │           │   └── main.yml
    │           ├── handlers/
    │           │   └── main.yml
    │           ├── tasks/
    │           │   └── main.yml
    │           ├── templates/
    │           │   └── index.html.j2
    │           ├── files/
    │           └── vars/
    ├── logs/
    │   └── day2-webserver.log
    └── README.md
```

> 🔥 **Important Fix:**  
> Roles **must** be inside `playbooks/roles/` because Ansible searches this path by default.

---

# 1️⃣ Create Folders

Run:

```bash
cd ~/devops-local-e2e-practice

mkdir -p Week4/Day2-Ansible-Roles-WebServer/{inventory,playbooks,logs}
mkdir -p Week4/Day2-Ansible-Roles-WebServer/playbooks/roles/webserver/{tasks,handlers,templates,files,defaults,vars}
```

---

# 2️⃣ Inventory (localhost)

Create:

```bash
cd Week4/Day2-Ansible-Roles-WebServer/inventory

cat > hosts.ini << 'EOF'
[web]
localhost ansible_connection=local
EOF
```

Test:

```bash
ansible -i hosts.ini web -m ping
```

---

# 3️⃣ Role: `webserver`

## 3.1 defaults/main.yml

```bash
cd playbooks/roles/webserver/defaults

cat > main.yml << 'EOF'
---
web_package: nginx
web_service: nginx
web_root: /var/www/html
web_server_name: localhost
web_listen_port: 80
EOF
```

---

## 3.2 tasks/main.yml

```bash
cd ../tasks

cat > main.yml << 'EOF'
---
- name: Update apt cache
  ansible.builtin.apt:
    update_cache: yes
    cache_valid_time: 3600
  become: true

- name: Install nginx
  ansible.builtin.apt:
    name: "{{ web_package }}"
    state: present
  become: true

- name: Ensure web root exists
  ansible.builtin.file:
    path: "{{ web_root }}"
    state: directory
    owner: www-data
    group: www-data
    mode: '0755'
  become: true

- name: Deploy index page
  ansible.builtin.template:
    src: index.html.j2
    dest: "{{ web_root }}/index.html"
    owner: www-data
    group: www-data
    mode: '0644'
  notify: restart webserver
  become: true

- name: Ensure Nginx default site is enabled
  ansible.builtin.file:
    path: /etc/nginx/sites-enabled/default
    state: link
    src: /etc/nginx/sites-available/default
  become: true

- name: Ensure nginx service is running
  ansible.builtin.service:
    name: "{{ web_service }}"
    state: started
    enabled: true
  become: true
EOF
```

---

## 3.3 handlers/main.yml

```bash
cd ../handlers

cat > main.yml << 'EOF'
---
- name: restart webserver
  ansible.builtin.service:
    name: "{{ web_service }}"
    state: restarted
  become: true
EOF
```

---

## 3.4 Template: index.html.j2

```bash
cd ../templates

cat > index.html.j2 << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>DevOps Local Lab - Ansible Webserver</title>
</head>
<body>
    <h1>Welcome to DevOps Local Lab</h1>
    <p>This page is deployed by Ansible role: <strong>webserver</strong>.</p>
    <p>Host: {{ inventory_hostname }}</p>
    <p>Environment: {{ env_name | default('dev') }}</p>
    <p>Date: {{ ansible_date_time.date }} Time: {{ ansible_date_time.time }}</p>
</body>
</html>
EOF
```

---

# 4️⃣ Playbook (site.yml)

```bash
cd ../../..

cd playbooks

cat > site.yml << 'EOF'
---
- name: Week4 Day2 - Configure Nginx web server via role
  hosts: web
  become: true
  vars:
    env_name: "local-web-dev"

  roles:
    - webserver
EOF
```

---

# 5️⃣ Run Playbook

```bash
cd ~/devops-local-e2e-practice/Week4/Day2-Ansible-Roles-WebServer

ansible-playbook playbooks/site.yml -i inventory/hosts.ini | tee logs/day2-webserver.log
```

---

# 6️⃣ Test Webserver

### On VM:

```bash
curl -v http://localhost
```

### On Windows Host:

Open browser:  
```
http://192.168.56.60
```

You should see the custom HTML page deployed by Ansible.

---

# 7️⃣ Git Commands

```bash
cd ~/devops-local-e2e-practice

git add Week4/Day2-Ansible-Roles-WebServer
git commit -m "Week4-Day2: Ansible role-based Nginx webserver"
git push origin feature/Week4
```

---

# 🧾 Summary Commands (Quick Reference)

```bash
ansible -i inventory/hosts.ini web -m ping
ansible-playbook playbooks/site.yml -i inventory/hosts.ini
curl http://localhost
git add Week4/Day2-Ansible-Roles-WebServer
git commit -m "Week4-Day2 updates"
git push
```

---

# ✅ Outcome

You now have:

- A fully working **Ansible role**
- Clean project folder structure
- A webserver deployed with:
  - Nginx  
  - Custom HTML template  
  - Service enabled & restarted via handlers
- A perfect interview-ready explanation:
  > “We use Ansible roles to separate tasks, handlers, templates, and defaults when configuring services like Nginx.”

---

If you’re ready, say **“Start Week4-Day3”** and we’ll continue with **Ansible provisioning on real AWS EC2 instances**, including SSH key automation and inventory generation.

