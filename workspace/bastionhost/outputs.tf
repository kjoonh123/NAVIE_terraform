output "bastion_id" {
  value = module.ec2_instance.ec2_id
}

output "bastion_IP" {
    value = "${module.ec2_instance.ec2_ip}/32"
}

output "EIP_public_ip" {
  value = aws_eip.BastionHost_eip.public_ip
}