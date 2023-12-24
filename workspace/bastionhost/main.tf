 # Terraform 초기구성
terraform {
  backend "s3" {
    bucket         = "navie-bucket-state-navie-web-project"
    key            = "aws_terraform/navie_bastion.tfstate"
    region         = "ap-northeast-2"
    profile        = "hong"

    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "ap-northeast-2"
  profile = "hong"
}

module "BastionHost_SG" {
  source          = "terraform-aws-modules/security-group/aws"
  version         = "5.1.0"
  name            = "BastionHost_SG"
  description     = "BastionHost_SG"
  vpc_id          = local.vpc_id
  use_name_prefix = "false"

  ingress_with_cidr_blocks = [
    {
      from_port   = local.ssh_port
      to_port     = local.ssh_port
      protocol    = local.tcp_protocol
      description = "SSH"
      cidr_blocks = local.all_network
    },
    {
      from_port   = local.ssh1_port
      to_port     = local.ssh1_port
      protocol    = local.tcp_protocol
      description = "SSH3223"
      cidr_blocks = local.all_network
    }

  ]
  egress_with_cidr_blocks = [
    {
      from_port   = local.any_port
      to_port     = local.any_port
      protocol    = local.any_protocol
      cidr_blocks = local.all_network
    }
  ]
}

# BastionHost EIP
resource "aws_eip" "BastionHost_eip" {
  instance = module.ec2_instance.ec2_id
  tags = {
    Name = "BastionHost_EIP"
  }
}

module "ec2_instance" {
  source                 = "../../modules/ec2_instance"
  ec2_name               = "BastionHost"
  ec2_ami                = "ami-086cae3329a3f7d75" //ubuntu(22.04LTS)
  ec2_type               = "t2.medium"
  user_data = <<-EOF
              #!/bin/bash
              sudo sed -i 's/#Port 22/Port 3223/g' /etc/ssh/sshd_config
              sudo systemctl restart sshd
EOF
  ec2_keyname            = data.aws_key_pair.EC2-Key.key_name
  subnet_id              = data.terraform_remote_state.vpc_remote_data.outputs.public_subnets[1]
  ec2_security_group_ids = [data.terraform_remote_state.eks_cluster_remote_data.outputs.eks_cluster_sg_id, module.BastionHost_SG.security_group_id] #data.terraform_remote_state.rds_remote_data.outputs.rds_db_sg, 
}