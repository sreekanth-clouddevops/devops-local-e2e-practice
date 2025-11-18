# Week 3 – Day 1: Terraform Basics on AWS (EC2)

## 🎯 Objectives
- Install and configure Terraform on Ubuntu
- Understand Terraform workflow: init → fmt → validate → plan → apply → destroy
- Configure AWS provider using existing AWS CLI credentials
- Create a simple EC2 instance in the default VPC
- Capture outputs (instance ID, public IP/DNS)
- Destroy resources safely to avoid cost

---

## 🧠 Concept Notes (Interview / Training)

### What is Terraform?
- **Infrastructure as Code (IaC)** tool by HashiCorp
- Manages infrastructure lifecycle (create, update, delete) using declarative configuration files (`.tf`)
- Works with many providers: AWS, Azure, GCP, Kubernetes, etc.

### Core Terraform Files
| File | Purpose |
|------|---------|
| `provider.tf` | Defines providers and required versions |
| `variables.tf` | Declares input variables |
| `main.tf` | Main resources (EC2, VPC, etc.) |
| `outputs.tf` | Exposes useful resource attributes |

### Terraform Workflow
1. **Write** `.tf` files  
2. `terraform init` – initialize providers  
3. `terraform fmt` – format code  
4. `terraform validate` – check correctness  
5. `terraform plan` – show execution plan  
6. `terraform apply` – create/update infrastructure  
7. `terraform destroy` – clean up resources  

---

## 🔧 Environment Setup

**Run in Ubuntu VM:**
```bash
sudo apt-get update -y
sudo apt-get install -y gnupg software-properties-common curl

curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
| sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt-get update -y
sudo apt-get install -y terraform

terraform version

