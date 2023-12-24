output "ec2_id" {
  value = module.ec2_instance.id
}

output "ec2_ip" {
  value = module.ec2_instance.private_ip
}