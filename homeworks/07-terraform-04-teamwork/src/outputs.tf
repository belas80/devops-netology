output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_user" {
  value = data.aws_caller_identity.current.user_id
}

output "region" {
  value = data.aws_region.current.description
}

output "instance_server01_private_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.ec2_instance["server01"].private_ip
}

output "instance_server02_private_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.ec2_instance["server02"].private_ip
}

output "instance_server01_public_ip" {
  description = "Private IP address of the EC2 instance"
  value       = module.ec2_instance["server01"].public_ip
}

output "instance_server02_public_ip" {
  description = "Private IP address of the EC2 instance"
  value       = module.ec2_instance["server02"].public_ip
}

