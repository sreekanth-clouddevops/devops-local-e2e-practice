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
  source = "../../modules/ec2_web"

  project_name  = var.project_name_prefix
  instance_type = var.instance_type
  environment   = var.environment
}

