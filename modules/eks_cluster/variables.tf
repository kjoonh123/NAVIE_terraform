locals {
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  cluster_admin   = var.cluster_admin
  tags = {
    cluster_name = var.cluster_name
  }
  vpc_id  = var.vpc_id
  subnets = var.subnets
}

variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
}

variable "cluster_version" {
  description = "EKS Cluster Version"
  type        = string
}

variable "cluster_admin" {
  description = "Cluster Admin IAM User Account ID"
  type        = string
}

variable "vpc_id" {
  description = "vpc_id"
  type        = string
}

variable "subnets" {
  description = "work node subnets_select"
  type        = list(any)
}