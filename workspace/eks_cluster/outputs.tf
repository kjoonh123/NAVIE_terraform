output "eks_cluster_sg_id" {
  value = module.eks_cluster.eks_cluster_sg_id
}

output "eks_cluster_oidc_arn" {
  value = module.eks_cluster.eks_cluster_oidc_arn
  description = "eks_cluster_oidc"
  # arn:aws:iam::188870935142:oidc-provider/oidc.eks.ap-northeast-2.amazonaws.com/id/CC80FCAFA9624D252832BC361144C586
}

output "eks_cluster_oidc" {
  value = module.eks_cluster.eks_cluster_oidc
  description = "eks_cluster_oidc"
  # oidc.eks.ap-northeast-2.amazonaws.com/id/CC80FCAFA9624D252832BC361144C586
}