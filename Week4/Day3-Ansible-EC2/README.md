# Week 4 – Day 3: Ansible on AWS EC2 (Public IP SSH + Inventory + Playbooks)

## 🎯 Objectives

- Launch EC2 instances (web + app)
- Create SSH key pair for Ansible
- Import SSH key into AWS
- Retrieve **public IPs** (not private IPs, since Vagrant cannot reach AWS VPC private IPs)
- Configure **SSH + Inventory** for Ansible
- Test connectivity (ping)
- Run a basic playbook (install packages, create files)
- Prepare for Day4 (Ansible Roles on EC2)

---

# 1️⃣ Folder Structure

```
Week4/
└── Day3-Ansible-EC2/
    ├── inventory/
    │   └── hosts.ini
    ├── keys/
    │   ├── devops-keypair
    │   └── devops-keypair.pub
    ├── playbooks/
    │   └── setup.yml
    ├── logs/
    └── README.md
```

---

# 2️⃣ Generate SSH Key Pair

```
cd Week4/Day3-Ansible-EC2/keys

ssh-keygen -t rsa -b 4096 -f devops-keypair -N ""
chmod 600 devops-keypair
```

This key will be used by Ansible and SSH both.

---

# 3️⃣ Import Public Key to AWS

```
aws ec2 import-key-pair \
  --key-name "devops-keypair" \
  --public-key-material fileb://devops-keypair.pub
```

Verify it:

```
aws ec2 describe-key-pairs --key-name devops-keypair
```

---

# 4️⃣ Launch EC2 Instances

### Fetch latest Ubuntu 22.04 AMI

```
AMI=$(aws ec2 describe-images \
  --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" \
  --query "Images | sort_by(@,&CreationDate)[-1].ImageId" --output text)
```

### Launch Webserver EC2

```
WEB_ID=$(aws ec2 run-instances --image-id $AMI --count 1 --instance-type t2.micro \
  --key-name devops-keypair \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=webserver-ec2}]' \
  --query "Instances[0].InstanceId" --output text)
```

### Launch Appserver EC2

```
APP_ID=$(aws ec2 run-instances --image-id $AMI --count 1 --instance-type t2.micro \
  --key-name devops-keypair \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=appserver-ec2}]' \
  --query "Instances[0].InstanceId" --output text)
```

### Wait for both instances to start

```
aws ec2 wait instance-running --instance-ids $WEB_ID $APP_ID
```

---

# 5️⃣ Get **Public IPs** for Inventory

> ⚠️ **Important:** Vagrant cannot reach private EC2 IPs.  
> So we always use **public IPs** for Ansible over SSH.

### Webserver public IP:

```
WEB_PUBLIC_IP=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=webserver-ec2" "Name=instance-state-name,Values=running" \
  --query "Reservations[0].Instances[0].PublicIpAddress" \
  --output text)

echo $WEB_PUBLIC_IP
```

### Appserver public IP:

```
APP_PUBLIC_IP=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=appserver-ec2" "Name=instance-state-name,Values=running" \
  --query "Reservations[0].Instances[0].PublicIpAddress" \
  --output text)

echo $APP_PUBLIC_IP
```

---

# 6️⃣ Security Group – Allow SSH from Your Local IP

EC2 will **reject SSH** unless allowed in SG.

### Get the Security Group used by the instances:

```
SG_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=webserver-ec2" \
  --query "Reservations[0].Instances[0].SecurityGroups[0].GroupId" --output text)
```

### Get your public IP:

```
MY_IP=$(curl -s https://checkip.amazonaws.com)
echo $MY_IP
```

### Allow SSH only from your IP (recommended):

```
aws ec2 authorize-security-group-ingress \
  --group-id "$SG_ID" \
  --protocol tcp \
  --port 22 \
  --cidr "${MY_IP}/32"
```

---

# 7️⃣ Create Inventory Using **Public IPs**

```
cd Week4/Day3-Ansible-EC2/inventory

cat > hosts.ini << EOF
[web]
${WEB_PUBLIC_IP} ansible_user=ubuntu ansible_ssh_private_key_file=../keys/devops-keypair

[app]
${APP_PUBLIC_IP} ansible_user=ubuntu ansible_ssh_private_key_file=../keys/devops-keypair
EOF
```

Check inventory:

```
cat hosts.ini
```

---

# 8️⃣ Test SSH + Ansible Connectivity

### Test raw SSH:

```
ssh -i keys/devops-keypair ubuntu@$WEB_PUBLIC_IP
exit
```

### Test Ansible:

```
ansible -i inventory/hosts.ini web -m ping
ansible -i inventory/hosts.ini app -m ping
```

Expected:

```
pong
```

---

# 9️⃣ Create Playbook: setup.yml

```
cd Week4/Day3-Ansible-EC2/playbooks

cat > setup.yml << 'EOF'
---
- name: Week4 Day3 - EC2 setup test
  hosts: all
  become: true

  tasks:
    - name: Install tree
      apt:
        name: tree
        state: present
        update_cache: yes

    - name: Create directory
      file:
        path: /opt/ansible-demo
        state: directory
        mode: '0755'

    - name: Create test file
      copy:
        content: "Managed by Ansible on {{ inventory_hostname }}"
        dest: /opt/ansible-demo/info.txt
        mode: '0644'
EOF
```

---

# 🔟 Run the Playbook

```
cd Week4/Day3-Ansible-EC2

ansible-playbook -i inventory/hosts.ini playbooks/setup.yml | tee logs/day3-run.log
```

---

# 1️⃣1️⃣ Verify on EC2

SSH:

```
ssh -i keys/devops-keypair ubuntu@$WEB_PUBLIC_IP
```

Check files:

```
tree
cat /opt/ansible-demo/info.txt
```

Repeat for the app server.

---

# 1️⃣2️⃣ Git Commit & Push

```
cd ~/devops-local-e2e-practice
git add Week4/Day3-Ansible-EC2
git commit -m "Week4-Day3: Updated README + EC2 public IP Ansible setup"
git push origin feature/Week4
```

---

# ✅ Final Outcome

By completing Week4-Day3:

- You launched **real AWS EC2 instances**
- Created & imported SSH keys
- Allowed SSH access using Security Group rules
- Used **public IPs** for Ansible connectivity
- Successfully ran Ansible playbooks against EC2
- Prepared environment for:
  - **Day4: Ansible roles on EC2 (web/app deployment)**
  - **Day5: Ansible Dynamic Inventory from AWS EC2 tags**

This completes **Week4-Day3** fully.


