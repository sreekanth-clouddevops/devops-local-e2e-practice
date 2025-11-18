output "dev_instance_id" {
  description = "Dev EC2 instance ID"
  value       = module.ec2_web.instance_id
}

output "dev_instance_public_ip" {
  description = "Dev EC2 instance public IP"
  value       = module.ec2_web.instance_public_ip
}

output "dev_instance_public_dns" {
  description = "Dev EC2 instance public DNS"
  value       = module.ec2_web.instance_public_dns
}

