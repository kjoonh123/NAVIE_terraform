data "terraform_remote_state" "eks_remote_data" {
  backend = "s3"
  config = {
    bucket  = "navie-bucket-state-navie-web-project"
    key     = "aws_terraform/navie_eks.tfstate"
    profile = "hong"
    region  = "ap-northeast-2"
  }
}

data "aws_caller_identity" "current" {}