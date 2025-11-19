terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "devops-local-tfstate-953816747017"
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

  project_name = "devops-local-lab"
  environment  = var.environment
  vpc_cidr     = "10.20.0.0/16"

  public_subnets  = ["10.20.1.0/24", "10.20.2.0/24"]
  private_subnets = ["10.20.11.0/24", "10.20.12.0/24"]

  azs = ["us-east-1a", "us-east-1b"]
}
