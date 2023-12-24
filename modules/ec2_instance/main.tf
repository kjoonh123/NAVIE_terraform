module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = var.ec2_name

  ami = var.ec2_ami
  instance_type          = var.ec2_type
  key_name               = var.ec2_keyname
  monitoring             = true
  user_data = var.user_data
  vpc_security_group_ids = var.ec2_security_group_ids
  subnet_id              = var.subnet_id

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}