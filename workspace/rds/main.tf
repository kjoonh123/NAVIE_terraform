# Terraform 초기구성
terraform {
  backend "s3" {
    bucket         = "navie-bucket-state-navie-web-project"
    key            = "aws_terraform/navie_db.tfstate"
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

module "rds" {
  source                = "../../modules/rds"
  vpc_id                = data.terraform_remote_state.vpc_remote_data.outputs.vpc_id
  db_port               = 3306
  allow_subnet1         = data.terraform_remote_state.vpc_remote_data.outputs.private_subnets_cidr_blocks[0]
  allow_subnet2         = data.terraform_remote_state.vpc_remote_data.outputs.private_subnets_cidr_blocks[1]
  allow_subnet3         = data.terraform_remote_state.bastion_remote_data.outputs.bastion_IP
  db_name               = "navie"
  db_username           = "admin"
  db_password           = "password123"
  database_subnet_group = data.terraform_remote_state.vpc_remote_data.outputs.database_subnet_group
  database_subnets      = data.terraform_remote_state.vpc_remote_data.outputs.database_subnets
}