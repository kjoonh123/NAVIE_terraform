# Terraform 초기구성
terraform {
  backend "s3" {
    bucket         = "navie-bucket-state-navie-web-project"
    key            = "aws_terraform/navie_eks.tfstate"
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

module "eks_cluster" {
  source          = "../../modules/eks_cluster"
  cluster_name    = "navie-eks"
  cluster_version = "1.27"
  cluster_admin   = data.aws_iam_user.EKS_Admin_ID.user_id
  vpc_id          = data.terraform_remote_state.vpc_remote_data.outputs.vpc_id
  subnets         = data.terraform_remote_state.vpc_remote_data.outputs.private_subnets
}

// Private Subnet Tag ( AWS Load Balancer Controller Tag / internal )
resource "aws_ec2_tag" "private_subnet_tag" {
  for_each    = toset(data.terraform_remote_state.vpc_remote_data.outputs.private_subnets)  #(module.vpc.private_subnets)
  resource_id = each.value
  key         = "kubernetes.io/role/internal-elb"
  value       = "1"
}

// Public Subnet Tag ( AWS Load Balancer Controller Tag / internet-facing )
resource "aws_ec2_tag" "public_subnet_tag" {
  for_each    = toset(data.terraform_remote_state.vpc_remote_data.outputs.public_subnets)
  resource_id = each.value
  key         = "kubernetes.io/role/elb"
  value       = "1"
}