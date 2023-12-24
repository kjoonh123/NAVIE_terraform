locals {
  tcp_protocol = "tcp"
  any_port     = 0
  any_protocol = "-1"
  all_network  = "0.0.0.0/0"
}

variable "vpc_id" {
  description = "vpc_id"
  type        = string
}

variable "db_port" {
  description = "RDS DB Port"
  type        = string
}

variable "allow_subnet1" {
  description = "Allow subnet"
  type        = string
}

variable "allow_subnet2" {
  description = "Allow subnet"
  type        = string
}

variable "allow_subnet3" {
  description = "Allow subnet"
  type        = string
}

variable "db_name" {
  description = "RDS DB Name"
  type        = string
}

variable "db_username" {
  description = "RDS DB UserName"
  type        = string
}

variable "db_password" {
  description = "RDS DB Password"
  type        = string
}

variable "database_subnet_group" {
  description = "RDS DB subnet_group"
  type        = string
}

variable "database_subnets" {
  description = "RDS DB subnets"
  type        = list(any)
}
