# Week 3 – Day 5: Terraform + Jenkins CI/CD (Plan / Apply / Destroy with Remote State)

## 🎯 Objectives

- Integrate **Terraform** with **Jenkins** using a Declarative Pipeline
- Use **remote backend** (S3 + DynamoDB) for Terraform state and locking
- Allow Jenkins to run:
  - `terraform init`
  - `terraform fmt` & `terraform validate`
  - `terraform plan`
  - `terraform apply` (with manual approval)
  - `terraform destroy` (with manual approval)
- Reuse the **VPC module** created in Week3–Day3

---

## 🧱 Pre-requisites

Already completed in earlier days:

- Jenkins running on the Ubuntu Vagrant VM  
- Terraform installed (`terraform version`)  
- AWS CLI configured (`aws sts get-caller-identity` works)  
- S3 bucket and DynamoDB table created (Week3–Day4):
  - S3: `devops-local-tfstate-<ACCOUNT_ID>`
  - DynamoDB: `devops-tf-locks`
- VPC module exists at:  
  `Week3/Day3-Terraform-VPC/modules/vpc`

---

## 📁 Folder Structure for Day5

```bash
Week3/
└── Day5-Terraform-CICD/
    ├── Jenkinsfile
    └── envs/
        └── dev/
            ├── backend-and-main.tf
            ├── variables.tf
            └── outputs.tf
```

The VPC module is reused from:

```bash
Week3/
└── Day3-Terraform-VPC/
    └── modules/
        └── vpc/
            ├── main.tf
            ├── variables.tf
            └── outputs.tf
```

---

# 1️⃣ Create Day5 Terraform Environment

In the Ubuntu VM:

```bash
cd ~/devops-local-e2e-practice
mkdir -p Week3/Day5-Terraform-CICD/envs/dev
cd Week3/Day5-Terraform-CICD/envs/dev
```

---

## 1.1 `variables.tf`

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

## 1.2 `backend-and-main.tf`

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
    key            = "week3/day5/dev/terraform.tfstate"
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
  vpc_cidr         = "10.30.0.0/16"

  public_subnets  = ["10.30.1.0/24", "10.30.2.0/24"]
  private_subnets = ["10.30.11.0/24", "10.30.12.0/24"]

  azs = ["us-east-1a", "us-east-1b"]
}
```

Replace the placeholder bucket with your real Terraform state bucket created in Day4:

```bash
AWS_REGION=us-east-1
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
TF_BUCKET_NAME="devops-local-tfstate-${ACCOUNT_ID}"
grep bucket backend-and-main.tf

sed -i "s/REPLACE_TFSTATE_BUCKET/${TF_BUCKET_NAME}/g" backend-and-main.tf

grep bucket backend-and-main.tf
```

You should see something like:

```hcl
bucket         = "devops-local-tfstate-123456789012"
```

---

## 1.3 `outputs.tf`

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

# 2️⃣ Configure AWS Credentials in Jenkins

In Jenkins UI:

1. Go to: **Manage Jenkins → Credentials → (global) → Add Credentials**
2. Fill:
   - **Kind**: `Username with password`
   - **ID**: `aws-terraform-creds`
   - **Username**: `AWS_ACCESS_KEY_ID`
   - **Password**: `AWS_SECRET_ACCESS_KEY`
   - Description: `AWS creds for Terraform`
3. Save.

> If you use a different ID, make sure to update the Jenkinsfile `credentialsId` accordingly.

---

# 3️⃣ Create Jenkinsfile for Terraform Pipeline

In VM:

```bash
cd ~/devops-local-e2e-practice/Week3/Day5-Terraform-CICD
```

Create `Jenkinsfile`:

```groovy
pipeline {
  agent any

  parameters {
    choice(name: 'ACTION', choices: ['PLAN', 'APPLY', 'DESTROY'], description: 'Terraform action')
    string(name: 'AWS_REGION', defaultValue: 'us-east-1')
    string(name: 'ENVIRONMENT', defaultValue: 'dev')
  }

  environment {
    TF_WORKDIR = "Week3/Day5-Terraform-CICD/envs/dev"
  }

  stages {

    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Terraform Init') {
      steps {
        withCredentials([usernamePassword(
          credentialsId: 'aws-terraform-creds',
          usernameVariable: 'AWS_ACCESS_KEY_ID',
          passwordVariable: 'AWS_SECRET_ACCESS_KEY'
        )]) {
          sh """
            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
            export AWS_DEFAULT_REGION=${params.AWS_REGION}

            cd ${TF_WORKDIR}
            terraform init -input=false
          """
        }
      }
    }

    stage('Terraform Validate') {
      steps {
        sh """
          cd ${TF_WORKDIR}
          terraform fmt -check
          terraform validate
        """
      }
    }

    stage('Terraform Plan') {
      when { anyOf { expression { params.ACTION == "PLAN" }; expression { params.ACTION == "APPLY" } } }
      steps {
        withCredentials([usernamePassword(
          credentialsId: 'aws-terraform-creds',
          usernameVariable: 'AWS_ACCESS_KEY_ID',
          passwordVariable: 'AWS_SECRET_ACCESS_KEY'
        )]) {
          sh """
            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
            export AWS_DEFAULT_REGION=${params.AWS_REGION}

            cd ${TF_WORKDIR}
            terraform plan -out=tfplan -input=false \
              -var="environment=${params.ENVIRONMENT}" \
              -var="aws_region=${params.AWS_REGION}"
            terraform show tfplan
          """
        }
      }
    }

    stage('Apply') {
      when { expression { params.ACTION == "APPLY" } }
      steps {
        input message: "Apply Terraform changes?", ok: "Yes apply"
        withCredentials([usernamePassword(
          credentialsId: 'aws-terraform-creds',
          usernameVariable: 'AWS_ACCESS_KEY_ID',
          passwordVariable: 'AWS_SECRET_ACCESS_KEY'
        )]) {
          sh """
            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
            export AWS_DEFAULT_REGION=${params.AWS_REGION}

            cd ${TF_WORKDIR}
            terraform apply -input=false tfplan
          """
        }
      }
    }

    stage('Destroy') {
      when { expression { params.ACTION == "DESTROY" } }
      steps {
        input message: "Destroy AWS infra?", ok: "Yes destroy"
        withCredentials([usernamePassword(
          credentialsId: 'aws-terraform-creds',
          usernameVariable: 'AWS_ACCESS_KEY_ID',
          passwordVariable: 'AWS_SECRET_ACCESS_KEY'
        )]) {
          sh """
            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
            export AWS_DEFAULT_REGION=${params.AWS_REGION}

            cd ${TF_WORKDIR}
            terraform destroy -auto-approve \
              -var="environment=${params.ENVIRONMENT}" \
              -var="aws_region=${params.AWS_REGION}"
          """
        }
      }
    }
  }
  post {
    always {
      echo "Terraform pipeline completed (success or fail)."
    }
    success {
      echo "Terraform pipeline finished successfully."
    }
    failure {
      echo "Terraform pipeline failed."
    }
  }
}

```

---

# 4️⃣ Git Commit & Push

From repo root:

```bash
cd ~/devops-local-e2e-practice
git add Week3/Day5-Terraform-CICD
git commit -m "Week3-Day5: Terraform Jenkins CI/CD pipeline with remote state"
git push origin feature/Week3
```

---

# 5️⃣ Create Jenkins Pipeline Job

In Jenkins Web UI:

1. Click **New Item**
2. Name: `Week3-Day5-Terraform-CICD`
3. Type: **Pipeline** → OK
4. In **Pipeline** section:
   - Definition: **Pipeline script from SCM**
   - SCM: **Git**
     - Repository: `https://github.com/<your-username>/devops-local-e2e-practice.git`
     - Branch: `feature/Week3`
   - Script Path: `Week3/Day5-Terraform-CICD/Jenkinsfile`
5. Save.

---

# 6️⃣ Run the Pipeline

On the job page:

Click **Build with Parameters**.

### Parameters:

- `ACTION`:
  - `PLAN` → only plan
  - `APPLY` → plan + apply (with manual confirmation)
  - `DESTROY` → destroy infra (with manual confirmation)
- `AWS_REGION`: `us-east-1`
- `ENVIRONMENT`: `dev`

---

## 6.1 Example: PLAN only

- Set `ACTION = PLAN`
- Click **Build**
- Pipeline stages:
  - Checkout
  - Terraform Init
  - Validate
  - Plan + Show Plan
- No resources are created/changed, only plan is shown.

---

## 6.2 Example: APPLY

- Set `ACTION = APPLY`
- Pipeline stages:
  - Checkout
  - Init
  - Validate
  - Plan
  - **Input prompt:** “Apply Terraform changes for ENV=dev, REGION=us-east-1?”
  - After you click **Proceed**, it runs:  
    `terraform apply -input=false tfplan`

Check AWS Console → VPC → see your new `10.30.0.0/16` VPC & subnets.

---

## 6.3 Example: DESTROY

- Set `ACTION = DESTROY`
- Pipeline stages:
  - Checkout
  - Init
  - Validate
  - **Input prompt:** “Destroy Terraform-managed resources for ENV=dev?”
  - On **Proceed**, runs:  
    `terraform destroy -auto-approve ...`

VPC and all related resources are deleted.

---

# 7️⃣ Verify Remote State & Locking

Terraform uses the **S3 backend** and **DynamoDB locking**:

### 7.1 Check state in S3

```bash
AWS_REGION=us-east-1
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
TF_BUCKET_NAME="devops-local-tfstate-${ACCOUNT_ID}"

aws s3 ls s3://${TF_BUCKET_NAME}/week3/day5/dev/
```

You should see: `terraform.tfstate`

No local `terraform.tfstate` file should exist inside `envs/dev`.

---

### 7.2 Check DynamoDB locks (optional)

```bash
aws dynamodb scan --table-name devops-tf-locks
```

Typically empty when no operation is running.  
During `apply` or `destroy`, Terraform creates a lock item, then removes it afterwards.

---

# 8️⃣ Manual CLI Commands (Optional)

You can still run Terraform manually inside the VM for debugging:

```bash
cd ~/devops-local-e2e-practice/Week3/Day5-Terraform-CICD/envs/dev

terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform apply tfplan
terraform destroy
```

---

# 🧾 Interview / Training Notes

- **Remote backend (S3)**:
  - `bucket` – S3 bucket name
  - `key` – path of the state file in the bucket
  - `region` – S3 bucket region
  - `encrypt = true` – enables SSE (server-side encryption)
- **DynamoDB locking**:
  - Prevents two concurrent Terraform operations on the same state
  - Recommended when state is shared (teams / Jenkins / GitHub Actions)
- **Why Jenkins + Terraform?**
  - Controlled, auditable infrastructure changes
  - Approval steps (`input`) before apply/destroy
  - Can be integrated with PR flows and approvals
- **Typical CI/CD stages for Terraform**:
  1. Checkout
  2. Init
  3. Fmt & Validate
  4. Plan (save `tfplan`)
  5. Manual approval
  6. Apply
  7. Optional Destroy (for non-prod/sandbox)

---

# ✅ Outcome

By the end of **Week 3 – Day 5** you have:

- A working **Jenkins → Terraform** pipeline
- Terraform using **S3 remote state** & **DynamoDB locks**
- A reusable **VPC module** deployed via CI/CD
- A strong story for interviews:
  > “We use Jenkins to run Terraform with S3 remote state and DynamoDB locking for our AWS infra, including VPCs, subnets, and NAT gateways.”


