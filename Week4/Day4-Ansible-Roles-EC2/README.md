# Week 4 – Day 4: Ansible Roles on AWS EC2 (Web + App Deployment)
Updated to include **Step-0: Cleanup old EC2 instances** before starting Day4.

---

# 🧹 0️⃣ **Cleanup Before Starting Day4 (IMPORTANT)**

Before creating new roles and new playbooks, terminate any existing EC2 instances created during Week4-Day3.

## Why?
- Vagrant cannot reach old private IPs  
- Public IPs change on reboot  
- Old Day3 instances contain leftover files (tree, ansible-demo directory)  
- Day4 roles install nginx, Flask, systemd service — fresh servers avoid conflicts  
- Clean logs + predictable results for future practice

## How to clean up
### Option A — AWS Console
1. Go to **EC2 → Instances**
2. Select:
   - `webserver-ec2`
   - `appserver-ec2`
3. **Instance state → Terminate**

### Option B — AWS CLI
```
aws ec2 terminate-instances --instance-ids <WEB_ID> <APP_ID>
```

Wait until both reach **terminated** state before continuing.

---

# 🎯 Day4 Objectives

- Create **Ansible Roles**:
  - `webserver` → nginx + HTML template  
  - `appserver` → Python Flask app + systemd service  
- Deploy to **fresh EC2 instances**  
- Use **role-based playbook structure**  
- Validate via browser & curl  
- Prepare for Week4-Day5 (Dynamic AWS Inventory)

---

# 📁 Folder Structure

```
Week4/
└── Day4-Ansible-Roles-EC2/
    ├── inventory/
    │   └── hosts.ini
    ├── playbooks/
    │   └── site.yml
    ├── roles/
    │   ├── webserver/
    │   └── appserver/
    ├── logs/
    └── README.md
```

---

# 1️⃣ Create Folders

```
cd ~/devops-local-e2e-practice

mkdir -p Week4/Day4-Ansible-Roles-EC2/{inventory,playbooks,roles,logs}
mkdir -p Week4/Day4-Ansible-Roles-EC2/roles/{webserver,appserver}/{tasks,handlers,templates,files,defaults,vars}
```

---

# 2️⃣ Copy Inventory from Day3

```
cp Week4/Day3-Ansible-EC2/inventory/hosts.ini Week4/Day4-Ansible-Roles-EC2/inventory/
```

Ensure it contains **public IPs** of the new EC2 instances you will launch.

---

# 3️⃣ Create Webserver Role

## defaults
```
cd roles/webserver/defaults

cat > main.yml << 'EOF'
---
web_service: nginx
web_root: /var/www/html
env_name: "prod"
EOF
```

## tasks
```
cd ../tasks

cat > main.yml << 'EOF'
---
- name: Update apt cache
  apt:
    update_cache: yes
  become: true

- name: Install nginx
  apt:
    name: nginx
    state: present
  become: true

- name: Ensure web root exists
  file:
    path: "{{ web_root }}"
    state: directory
  become: true

- name: Deploy index.html
  template:
    src: index.html.j2
    dest: "{{ web_root }}/index.html"
  notify: restart nginx
  become: true

- name: Ensure nginx running
  service:
    name: nginx
    state: started
    enabled: true
  become: true
EOF
```

## handlers
```
cd ../handlers

cat > main.yml << 'EOF'
---
- name: restart nginx
  service:
    name: nginx
    state: restarted
  become: true
EOF
```

## template
```
cd ../templates

cat > index.html.j2 << 'EOF'
<!DOCTYPE html>
<html>
  <body>
    <h1>Welcome to Webserver (EC2)</h1>
    <p>Host: {{ inventory_hostname }}</p>
    <p>Environment: {{ env_name }}</p>
    <p>Deployed via Ansible Role</p>
  </body>
</html>
EOF
```

---

# 4️⃣ Create Appserver Role

## defaults
```
cd ../../appserver/defaults

cat > main.yml << 'EOF'
---
app_dir: /opt/simpleapp
service_name: simpleapp
EOF
```

## tasks
```
cd ../tasks

cat > main.yml << 'EOF'
---
- name: Update apt cache
  apt:
    update_cache: yes
  become: true

- name: Install Python
  apt:
    name:
      - python3
      - python3-pip
    state: present
  become: true

- name: Create app directory
  file:
    path: "{{ app_dir }}"
    state: directory
  become: true

- name: Deploy Flask app
  template:
    src: app.py.j2
    dest: "{{ app_dir }}/app.py"
  notify: restart app
  become: true

- name: Install Flask
  pip:
    name: flask
    executable: pip3
  become: true

- name: Create systemd service
  copy:
    dest: /etc/systemd/system/{{ service_name }}.service
    content: |
      [Unit]
      Description=Simple Flask App

      [Service]
      ExecStart=/usr/bin/python3 {{ app_dir }}/app.py
      Restart=always

      [Install]
      WantedBy=multi-user.target
  notify: restart app
  become: true

- name: Enable service
  systemd:
    name: "{{ service_name }}"
    enabled: true
    state: started
  become: true
EOF
```

## handlers
```
cd ../handlers

cat > main.yml << 'EOF'
---
- name: restart app
  systemd:
    name: "{{ service_name }}"
    state: restarted
  become: true
EOF
```

## Flask app template
```
cd ../templates

cat > app.py.j2 << 'EOF'
from flask import Flask
app = Flask(__name__)

@app.route("/")
def index():
    return "Hello from App Server ({{ inventory_hostname }}) via Flask!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
EOF
```

---

# 5️⃣ Create the Main Playbook

```
cd ~/devops-local-e2e-practice/Week4/Day4-Ansible-Roles-EC2/playbooks

cat > site.yml << 'EOF'
---
- name: Configure Webserver EC2
  hosts: web
  become: true
  roles:
    - webserver

- name: Configure Appserver EC2
  hosts: app
  become: true
  roles:
    - appserver
EOF
```

---

# 6️⃣ Run the Playbook

```
cd ~/devops-local-e2e-practice/Week4/Day4-Ansible-Roles-EC2

ansible-playbook -i inventory/hosts.ini playbooks/site.yml | tee logs/day4-run.log
```

---

# 7️⃣ Validate Deployment

## Web Server Test
```
curl http://WEB_PUBLIC_IP
```
Browser (Windows):
```
http://WEB_PUBLIC_IP
```

---

## App Server Test
```
curl http://APP_PUBLIC_IP:5000
```

Expected:

```
Hello from App Server (...) via Flask!
```

---

# 8️⃣ Git Commit & Push

```
cd ~/devops-local-e2e-practice

git add Week4/Day4-Ansible-Roles-EC2
git commit -m "Week4-Day4: Roles deployed to EC2 (Web + App)"
git push origin feature/Week4
```

---

# ✅ Day4 Completed

You now have:
- Role-based deployment  
- Web & App servers on EC2  
- Nginx + Flask running via systemd  
- A real production-like setup

Next: **Week4-Day5 → AWS Dynamic Inventory**  
(automatic EC2 discovery via tags)


