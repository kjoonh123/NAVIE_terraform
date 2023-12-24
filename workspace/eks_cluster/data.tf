# AWS EKS Cluster
data "aws_iam_user" "EKS_Admin_ID" {
  user_name = "admin"
}

#module vpc data
data "terraform_remote_state" "vpc_remote_data" {
  backend = "s3"
  config = {
    bucket  = "navie-bucket-state-navie-web-project"
    key     = "aws_terraform/navie_vpc.tfstate"
    profile = "hong"
    region  = "ap-northeast-2"
  }
}