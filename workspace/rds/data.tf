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

data "terraform_remote_state" "bastion_remote_data" {
  backend = "s3"
  config = {
    bucket  = "navie-bucket-state-navie-web-project"
    key     = "aws_terraform/navie_bastion.tfstate"
    profile = "hong"
    region  = "ap-northeast-2"
  }
}