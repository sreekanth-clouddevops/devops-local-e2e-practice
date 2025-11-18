variable "aws_region" {
  description = "AWS region for dev environment"
  type        = string
  default     = "us-east-1"
}

variable "project_name_prefix" {
  description = "Base project name prefix"
  type        = string
  default     = "devops-local-lab"
}

variable "instance_type" {
  description = "EC2 instance type for dev"
  type        = string
  default     = "t2.micro"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

