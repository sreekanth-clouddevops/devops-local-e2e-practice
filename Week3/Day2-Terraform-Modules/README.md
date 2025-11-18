# Week 3 – Day 2: Terraform Modules & Multiple Environments (dev / qa)

## 🎯 Objectives
- Create reusable Terraform module (`ec2_web`)
- Create two environments (`dev` and `qa`)
- Deploy EC2 using module
- Learn clean multi-environment structure
- Understand plan/apply/destroy per environment

---

# 📁 Directory Structure

```
Week3/
└── Day2-Terraform-Modules/
    ├── modules/
    │   └── ec2_web/
    │       ├── main.tf
    │       ├── variables.tf
    │       └── outputs.tf
    └── envs/
        ├── dev/
        │   ├── main.tf
        │   ├── variables.tf
        │   └── outputs.tf
        └── qa/
            ├── main.tf
            ├── variables.tf
            └── outputs.tf
```

---

# 1️⃣ Create Directories

```bash
cd ~/devops-local-e2e-practice
mkdir -p Week3/Day2-Terraform-Modules/modules/ec2_web
mkdir -p Week3/Day2-Terraform-Modules/envs/dev
mkdir -p Week3/Day2-Terraform-Modules/envs/qa
```

---

# 2️⃣ Module Code (Reusable EC2 Module)

## modules/ec2_web/variables.tf

```hcl
variable "project_name" {
  description = "Project name prefix for tagging"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "environment" {
  description = "Environment name (dev, qa, prod)"
  type        = string
}
```

---

## modules/ec2_web/main.tf

```hcl
# Lookup Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Default VPC
data "aws_vpc" "default" {
  default = true
}

# All subnets in default VPC
data "aws_subnets" "default_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security Group
resource "aws_security_group" "web_sg" {
  name        = "${var.project_name}-${var.environment}-web-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-web-sg"
    Environment = var.environment
  }
}

# EC2 instance
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  subnet_id              = element(data.aws_subnets.default_subnets.ids, 0)
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name        = "${var.project_name}-${var.environment}-web-ec2"
    Environment = var.environment
  }
}
```

---

## modules/ec2_web/outputs.tf

```hcl
output "instance_id" {
  value = aws_instance.web.id
}

output "instance_public_ip" {
  value = aws_instance.web.public_ip
}

output "instance_public_dns" {
  value = aws_instance.web.public_dns
}

output "security_group_id" {
  value = aws_security_group.web_sg.id
}
```

---

# 3️⃣ Dev Environment

## envs/dev/variables.tf

```hcl
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name_prefix" {
  type    = string
  default = "devops-local-lab"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "environment" {
  type    = string
  default = "dev"
}
```

---

## envs/dev/main.tf

```hcl
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "ec2_web" {
  source        = "../../modules/ec2_web"
  project_name  = var.project_name_prefix
  instance_type = var.instance_type
  environment   = var.environment
}
```

---

## envs/dev/outputs.tf

```hcl
output "dev_instance_id" {
  value = module.ec2_web.instance_id
}

output "dev_instance_public_ip" {
  value = module.ec2_web.instance_public_ip
}

output "dev_instance_public_dns" {
  value = module.ec2_web.instance_public_dns
}
```

---

# 4️⃣ QA Environment

## envs/qa/variables.tf

```hcl
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name_prefix" {
  type    = string
  default = "devops-local-lab"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "environment" {
  type    = string
  default = "qa"
}
```

---

## envs/qa/main.tf

```hcl
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "ec2_web" {
  source        = "../../modules/ec2_web"
  project_name  = var.project_name_prefix
  instance_type = var.instance_type
  environment   = var.environment
}
```

---

## envs/qa/outputs.tf

```hcl
output "qa_instance_id" {
  value = module.ec2_web.instance_id
}

output "qa_instance_public_ip" {
  value = module.ec2_web.instance_public_ip
}

output "qa_instance_public_dns" {
  value = module.ec2_web.instance_public_dns
}
```

---

# 5️⃣ Deploy Dev Environment

```bash
cd ~/devops-local-e2e-practice/Week3/Day2-Terraform-Modules/envs/dev

terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan-dev
terraform apply tfplan-dev
```

### 🔍 View plan file
```bash
terraform show tfplan-dev
```

### Destroy after testing
```bash
terraform destroy
```

---

# 6️⃣ Deploy QA Environment

```bash
cd ~/devops-local-e2e-practice/Week3/Day2-Terraform-Modules/envs/qa

terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan-qa
terraform apply tfplan-qa
```

### 🔍 View plan file
```bash
terraform show tfplan-qa
```

### Destroy when done
```bash
terraform destroy
```

---

# 7️⃣ Git Commands

```bash
cd ~/devops-local-e2e-practice
git add Week3/Day2-Terraform-Modules
git commit -m "Week3-Day2: Terraform modules with dev and qa"
git push origin feature/Week3
```

---

# 🧾 Quick Summary Commands (All Together)

### Dev
```bash
cd Week3/Day2-Terraform-Modules/envs/dev
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan-dev
terraform show tfplan-dev
terraform apply tfplan-dev
terraform destroy
```

### QA
```bash
cd Week3/Day2-Terraform-Modules/envs/qa
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan-qa
terraform show tfplan-qa
terraform apply tfplan-qa
terraform destroy
```

### Git
```bash
cd ~/devops-local-e2e-practice
git add Week3/Day2-Terraform-Modules
git commit -m "Week3-Day2: Terraform modules with dev and qa"
git push origin feature/Week3
```

---

# ✅ Day 2 Complete
This sets the foundation for Day 3:
- Full custom VPC
- Subnets (public/private)
- IGW
- NAT Gateway
- Route Tables
- EC2 inside subnets
