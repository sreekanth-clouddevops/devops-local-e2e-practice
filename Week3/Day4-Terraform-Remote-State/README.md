# Week 3 – Day 4: Terraform Remote State (S3 Backend + DynamoDB Locking)

## 🎯 Objectives
- Store Terraform state in **S3** instead of local file
- Enable **state locking** using **DynamoDB**
- Reuse existing **VPC module** from Week3-Day3
- Understand how teams safely share Terraform state

---

# 1️⃣ Folder Structure

```
Week3/
└── Day4-Terraform-Remote-State/
    ├── README.md
    └── envs/
        └── dev/
            ├── backend-and-main.tf
            ├── variables.tf
            └── outputs.tf
```

VPC module is reused from Day3:

```
Week3/
└── Day3-Terraform-VPC/
    └── modules/
        └── vpc/
            ├── main.tf
            ├── variables.tf
            └── outputs.tf
```

---

# 2️⃣ Create S3 Bucket for Terraform State

In Ubuntu VM:

```bash
AWS_REGION=us-east-1
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
TF_BUCKET_NAME="devops-local-tfstate-${ACCOUNT_ID}"
echo "Bucket name: ${TF_BUCKET_NAME}"
```

Create bucket (for `us-east-1`):

```bash
aws s3api create-bucket \
  --bucket "${TF_BUCKET_NAME}" \
  --region "${AWS_REGION}"
```

Verify:

```bash
aws s3 ls
```

---

# 3️⃣ Create DynamoDB Table for State Locking

```bash
aws dynamodb create-table \
  --table-name devops-tf-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```

Verify:

```bash
aws dynamodb describe-table --table-name devops-tf-locks \
  --query "Table.[TableName,TableStatus,ItemCount]" \
  --output table
```

---

# 4️⃣ Day4 Dev Environment Files

Go to Day4 dev env:

```bash
cd ~/devops-local-e2e-practice
mkdir -p Week3/Day4-Terraform-Remote-State/envs/dev
cd Week3/Day4-Terraform-Remote-State/envs/dev
```

---

## 4.1 variables.tf

```hcl
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}
```

---

## 4.2 backend-and-main.tf

```hcl
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "REPLACE_TFSTATE_BUCKET"
    key            = "week3/day4/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "devops-tf-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "../../../Day3-Terraform-VPC/modules/vpc"

  project_name     = "devops-local-lab"
  environment      = var.environment
  vpc_cidr         = "10.20.0.0/16"

  public_subnets  = ["10.20.1.0/24", "10.20.2.0/24"]
  private_subnets = ["10.20.11.0/24", "10.20.12.0/24"]

  azs = ["us-east-1a", "us-east-1b"]
}
```

Replace `REPLACE_TFSTATE_BUCKET`:

```bash
AWS_REGION=us-east-1
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
TF_BUCKET_NAME="devops-local-tfstate-${ACCOUNT_ID}"
sed -i "s/REPLACE_TFSTATE_BUCKET/${TF_BUCKET_NAME}/g" backend-and-main.tf
```

---

## 4.3 outputs.tf

```hcl
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}
```

---

# 5️⃣ Initialize Terraform with Remote Backend

```bash
cd ~/devops-local-e2e-practice/Week3/Day4-Terraform-Remote-State/envs/dev

terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

Use `terraform show` to inspect the plan:

```bash
terraform show tfplan
```

---

# 6️⃣ Verify Remote State & Locking

## 6.1 Check S3

```bash
aws s3 ls s3://${TF_BUCKET_NAME}/week3/day4/dev/
```

You should see:

- `terraform.tfstate`

No `terraform.tfstate` file should be present locally in the folder.

---

## 6.2 Check DynamoDB Locks (optional)

During `terraform apply`, Terraform creates a lock item in DynamoDB.

You can inspect:

```bash
aws dynamodb scan --table-name devops-tf-locks
```

When no run is in progress, scan usually returns zero items.

---

# 7️⃣ Destroy Infrastructure (Using Remote State)

```bash
cd ~/devops-local-e2e-practice/Week3/Day4-Terraform-Remote-State/envs/dev
terraform destroy
```

Terraform will:

- Read state from S3  
- Use DynamoDB table to lock  
- Destroy VPC, subnets, NAT, etc.  

State file in S3 will remain (empty resources after destroy).

---

# 8️⃣ Git Commands

```bash
cd ~/devops-local-e2e-practice
git add Week3/Day4-Terraform-Remote-State
git commit -m "Week3-Day4: Terraform remote backend with S3 and DynamoDB locking"
git push origin feature/Week3
```

---

# 🧾 Quick Interview Notes

- **Why remote state?**  
  - Share Terraform state between team members and CI  
  - Prevent local `terraform.tfstate` loss  
- **Why DynamoDB locking?**  
  - Prevents two `terraform apply` from modifying the same infra at the same time  
- **Backend block:**  
  - `bucket` – S3 bucket name  
  - `key` – path/key of state file in bucket  
  - `dynamodb_table` – table for lock records  
  - `encrypt = true` – server-side encryption of state file  
- **Important:**  
  - Backend config is usually **not** parameterized with variables  
  - Changing backend requires `terraform init -migrate-state`

---

# ✅ Outcome

- S3 bucket created for Terraform remote state  
- DynamoDB table created for Terraform state locking  
- VPC created using remote backend + module from Day3  
- No local `terraform.tfstate` used — state managed centrally  
- Ready for **Week 3 – Day 5: Terraform + Jenkins Pipeline (Plan/Apply in CI)**


