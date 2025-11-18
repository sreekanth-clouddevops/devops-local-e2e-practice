output "qa_instance_id" {
  description = "QA EC2 instance ID"
  value       = module.ec2_web.instance_id
}

output "qa_instance_public_ip" {
  description = "QA EC2 instance public IP"
  value       = module.ec2_web.instance_public_ip
}

output "qa_instance_public_dns" {
  description = "QA EC2 instance public DNS"
  value       = module.ec2_web.instance_public_dns
}

