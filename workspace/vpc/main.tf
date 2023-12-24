# Terraform 초기구성
terraform {
  backend "s3" {
    bucket         = "navie-bucket-state-navie-web-project"
    key            = "aws_terraform/navie_vpc.tfstate"
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

#vpc module
module "vpc" {
  source           = "../../modules/vpc"
  name             = "navie_vpc"
  cidr             = "192.168.0.0/16"
  public_subnets   = ["192.168.1.0/24", "192.168.2.0/24"]
  private_subnets  = ["192.168.10.0/24", "192.168.20.0/24"]
  database_subnets = ["192.168.30.0/24", "192.168.40.0/24"]
}