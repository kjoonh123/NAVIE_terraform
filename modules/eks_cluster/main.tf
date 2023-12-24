provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.31.0"

  # EKS Cluster Setting(k8)
  cluster_name                    = local.cluster_name
  cluster_version                 = local.cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  vpc_id                          = local.vpc_id
  subnet_ids                      = local.subnets # work node가 만들어 질 위치

  # OIDC(OpenID Connect) 구성 
  enable_irsa = true

  # EKS Worker Node 정의 ( ManagedNode방식 / Launch Template 자동 구성 )
  eks_managed_node_groups = {
    initial = {
      instance_types         = ["t3.medium"]
      create_security_group  = false
      create_launch_template = false # Required Option    Required Option은 없어서는 안되므로 false 또는 공란으로 둔다
      launch_template_name   = ""    # Required Option    공란 = ""

      min_size     = 2
      max_size     = 3
      desired_size = 2
    }
  }

  # K8s ConfigMap Object "aws_auth" 구성
  manage_aws_auth_configmap = true
  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::${local.cluster_admin}:user/admin"
      username = "admin"
      groups   = ["system:masters"]
    },
  ]
}

# // Private Subnet Tag ( AWS Load Balancer Controller Tag / internal )
# resource "aws_ec2_tag" "private_subnet_tag" {
#   for_each    = { for idx, subnet in module.vpc.private_subnets : idx => subnet }
#   resource_id = each.value
#   key         = "kubernetes.io/role/internal-elb"
#   value       = "1"
#   depends_on = [ module.eks ]
# }

# // Public Subnet Tag ( AWS Load Balancer Controller Tag / internet-facing )
# resource "aws_ec2_tag" "public_subnet_tag" {
#   for_each    = { for idx, subnet in module.vpc.public_subnets : idx => subnet }
#   resource_id = each.value
#   key         = "kubernetes.io/role/internal-elb"
#   value       = "1"
#   depends_on = [ module.eks ]
# }