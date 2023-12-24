# RDS SG
module "RDS_SG" {
  source          = "terraform-aws-modules/security-group/aws"
  version         = "5.1.0"
  name            = "RDS_SG1"
  description     = "DB Port Allow"
  vpc_id          = var.vpc_id
  use_name_prefix = "false"

  ingress_with_cidr_blocks = [
    {
      from_port   = var.db_port
      to_port     = var.db_port
      protocol    = local.tcp_protocol
      description = "DB Port Allow"
      cidr_blocks = var.allow_subnet1
    },
    {
      from_port   = var.db_port
      to_port     = var.db_port
      protocol    = local.tcp_protocol
      description = "DB Port Allow"
      cidr_blocks = var.allow_subnet2
    },
    {
      from_port   = var.db_port
      to_port     = var.db_port
      protocol    = local.tcp_protocol
      description = "DB Port Allow"
      cidr_blocks = var.allow_subnet3
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

module "rds" {
  source                              = "terraform-aws-modules/rds/aws"
  version                             = "6.1.1"
  identifier                          = "rds-navie"
  engine                              = "mysql"
  engine_version                      = "8.0.33"
  instance_class                      = "db.t3.micro"
  allocated_storage                   = 5
  multi_az                            = true       # 선택사항 (사용 : true)
  iam_database_authentication_enabled = true       # IAM 계정 RDS 인증 사용
  manage_master_user_password         = false      # SecretManager: True(기본값) / Password:false
  skip_final_snapshot                 = true       # RDS Instance 삭제 시 Snapshot 생성여부 결정
  family                              = "mysql8.0" # DB parameter group (Required Option)
  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]
  major_engine_version = "8.0" # DB option group (Required Option) Engine마다 지원하는 옵션이 다르다. 
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password # Env or Secret Manager 사용권장!
  port                 = var.db_port
  # DB subnet group & DB Security-Group
  # db_subnet_group_name   = data.terraform_remote_state.vpc_remote_data.outputs.database_subnet_group
  db_subnet_group_name   = var.database_subnet_group
  subnet_ids             = var.database_subnets
  vpc_security_group_ids = [module.RDS_SG.security_group_id]
}