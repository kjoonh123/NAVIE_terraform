locals {
  region           = "ap-northeast-2"
  azs              = ["ap-northeast-2a", "ap-northeast-2c"]
  name             = var.name
  cidr             = var.cidr
  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  database_subnets = var.database_subnets
  any_port         = 0
  any_protocol     = "-1"
  all_network      = "0.0.0.0/0"
}

variable "name" {
  description = "VPC name"
  type        = string
}

variable "cidr" {
  description = "VPC CIDR BLOCK"
  type        = string
}

variable "public_subnets" {
  description = "VPC Public Subnets"
  type        = list(any)
}

variable "private_subnets" {
  description = "VPC Private Subnets"
  type        = list(any)
}

variable "database_subnets" {
  description = "VPC Database Subnets"
  type        = list(any)
}