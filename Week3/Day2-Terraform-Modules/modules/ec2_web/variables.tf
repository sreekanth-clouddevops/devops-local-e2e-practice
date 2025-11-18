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
