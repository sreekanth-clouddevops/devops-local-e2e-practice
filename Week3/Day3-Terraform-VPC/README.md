# Week 3 – Day 3: Terraform VPC Module (VPC + Subnets + IGW + NAT + Routes)

## 🎯 Objectives
- Create production-grade VPC with public & private subnets
- Create IGW, NAT Gateway, Route Tables
- Use Terraform modules
- Build dev environment using module
- Learn real DevOps VPC design

---

# 📁 Folder Structure

```
Week3/
└── Day3-Terraform-VPC/
    ├── modules/
    │   └── vpc/
    │       ├── main.tf
    │       ├── variables.tf
    │       └── outputs.tf
    └── envs/
        └── dev/
            ├── main.tf
            ├── variables.tf
            └── outputs.tf
```

---

# 1️⃣ Module Code

## modules/vpc/variables.tf

```hcl
variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "azs" {
  type = list(string)
}
```

---

## modules/vpc/main.tf

```hcl
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${var.environment}-public-${count.index + 1}"
    Type = "public"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "${var.project_name}-${var.environment}-private-${count.index + 1}"
    Type = "private"
  }
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }
}

resource "aws_route_table_association" "private_assoc" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rt.id
}
```

---

## modules/vpc/outputs.tf

```hcl
output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}
```

---

# 2️⃣ Environment (DEV)

## envs/dev/variables.tf

```hcl
variable "aws_region" {
  default = "us-east-1"
}

variable "environment" {
  default = "dev"
}
```

---

## envs/dev/main.tf

```hcl
terraform {
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

module "vpc" {
  source = "../../modules/vpc"

  project_name     = "devops-local-lab"
  environment      = var.environment
  vpc_cidr         = "10.10.0.0/16"

  public_subnets  = ["10.10.1.0/24", "10.10.2.0/24"]
  private_subnets = ["10.10.11.0/24", "10.10.12.0/24"]
  azs             = ["us-east-1a", "us-east-1b"]
}
```

---

## envs/dev/outputs.tf

```hcl
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnet_ids
}

output "private_subnets" {
  value = module.vpc.private_subnet_ids
}
```

---

# 3️⃣ APPLY ENVIRONMENT

```bash
cd Week3/Day3-Terraform-VPC/envs/dev
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
terraform show tfplan
```

---

# 4️⃣ DESTROY ENVIRONMENT

```bash
terraform destroy
```

---

# 5️⃣ GIT COMMANDS

```bash
cd ~/devops-local-e2e-practice
git add Week3/Day3-Terraform-VPC
git commit -m "Week3-Day3: Terraform VPC module + dev environment"
git push origin feature/Week3
```

---

# ✅ Day 3 Complete!
You now have a **production-ready VPC** using Terraform modules.

Next:  
**Week3–Day4 → S3 Remote Backend + DynamoDB State Locking**

