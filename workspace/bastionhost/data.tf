##이부분 현재 수동으로 key 생성 /
# BastionHost Key-Pair DataSource
data "aws_key_pair" "EC2-Key" {
  key_name = "deploy"
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

#module eks_cluster data
data "terraform_remote_state" "eks_cluster_remote_data" {
  backend = "s3"
  config = {
    bucket  = "navie-bucket-state-navie-web-project"
    key     = "aws_terraform/navie_eks.tfstate"
    profile = "hong"
    region  = "ap-northeast-2"
  }
}