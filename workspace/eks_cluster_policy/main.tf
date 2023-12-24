terraform {
  backend "s3" {
    bucket         = "navie-bucket-state-navie-web-project"
    key            = "aws_terraform/navie_eks_policy.tfstate"
    region         = "ap-northeast-2"
    profile        = "hong"

    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.24.0"
    }
  }
}

provider "aws" {
  region  = "ap-northeast-2"
  profile = "hong"
}

provider "kubernetes" {
  config_path    = "~/.kube/kubeconfig"
  config_context = "navie-eks"
}

resource "aws_iam_policy" "AWSLoadBalancerControllerIAMPolicy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "AWSLoadBalancerControllerIAMPolicy"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateServiceLinkedRole"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:AWSServiceName": "elasticloadbalancing.amazonaws.com"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeAccountAttributes",
                "ec2:DescribeAddresses",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeInternetGateways",
                "ec2:DescribeVpcs",
                "ec2:DescribeVpcPeeringConnections",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeInstances",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeTags",
                "ec2:GetCoipPoolUsage",
                "ec2:DescribeCoipPools",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeLoadBalancerAttributes",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:DescribeListenerCertificates",
                "elasticloadbalancing:DescribeSSLPolicies",
                "elasticloadbalancing:DescribeRules",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetGroupAttributes",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:DescribeTags"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cognito-idp:DescribeUserPoolClient",
                "acm:ListCertificates",
                "acm:DescribeCertificate",
                "iam:ListServerCertificates",
                "iam:GetServerCertificate",
                "waf-regional:GetWebACL",
                "waf-regional:GetWebACLForResource",
                "waf-regional:AssociateWebACL",
                "waf-regional:DisassociateWebACL",
                "wafv2:GetWebACL",
                "wafv2:GetWebACLForResource",
                "wafv2:AssociateWebACL",
                "wafv2:DisassociateWebACL",
                "shield:GetSubscriptionState",
                "shield:DescribeProtection",
                "shield:CreateProtection",
                "shield:DeleteProtection"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupIngress"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateSecurityGroup"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags"
            ],
            "Resource": "arn:aws:ec2:*:*:security-group/*",
            "Condition": {
                "StringEquals": {
                    "ec2:CreateAction": "CreateSecurityGroup"
                },
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags",
                "ec2:DeleteTags"
            ],
            "Resource": "arn:aws:ec2:*:*:security-group/*",
            "Condition": {
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "true",
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:DeleteSecurityGroup"
            ],
            "Resource": "*",
            "Condition": {
                "Null": {
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:CreateLoadBalancer",
                "elasticloadbalancing:CreateTargetGroup"
            ],
            "Resource": "*",
            "Condition": {
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:DeleteListener",
                "elasticloadbalancing:CreateRule",
                "elasticloadbalancing:DeleteRule"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:RemoveTags"
            ],
            "Resource": [
                "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
            ],
            "Condition": {
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "true",
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:RemoveTags"
            ],
            "Resource": [
                "arn:aws:elasticloadbalancing:*:*:listener/net/*/*/*",
                "arn:aws:elasticloadbalancing:*:*:listener/app/*/*/*",
                "arn:aws:elasticloadbalancing:*:*:listener-rule/net/*/*/*",
                "arn:aws:elasticloadbalancing:*:*:listener-rule/app/*/*/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:ModifyLoadBalancerAttributes",
                "elasticloadbalancing:SetIpAddressType",
                "elasticloadbalancing:SetSecurityGroups",
                "elasticloadbalancing:SetSubnets",
                "elasticloadbalancing:DeleteLoadBalancer",
                "elasticloadbalancing:ModifyTargetGroup",
                "elasticloadbalancing:ModifyTargetGroupAttributes",
                "elasticloadbalancing:DeleteTargetGroup"
            ],
            "Resource": "*",
            "Condition": {
                "Null": {
                    "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:AddTags"
            ],
            "Resource": [
                "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
                "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
            ],
            "Condition": {
                "StringEquals": {
                    "elasticloadbalancing:CreateAction": [
                        "CreateTargetGroup",
                        "CreateLoadBalancer"
                    ]
                },
                "Null": {
                    "aws:RequestTag/elbv2.k8s.aws/cluster": "false"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:DeregisterTargets"
            ],
            "Resource": "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:SetWebAcl",
                "elasticloadbalancing:ModifyListener",
                "elasticloadbalancing:AddListenerCertificates",
                "elasticloadbalancing:RemoveListenerCertificates",
                "elasticloadbalancing:ModifyRule"
            ],
            "Resource": "*"
        }
    ]
  })
}

resource "aws_iam_role" "AmazonEKSLoadBalancerControllerRole" {
  name        = "AmazonEKSLoadBalancerControllerRole"
  description = "AmazonEKSLoadBalancerControllerRole"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "${data.terraform_remote_state.eks_remote_data.outputs.eks_cluster_oidc_arn}"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "${data.terraform_remote_state.eks_remote_data.outputs.eks_cluster_oidc}:aud": "sts.amazonaws.com",
            "${data.terraform_remote_state.eks_remote_data.outputs.eks_cluster_oidc}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy_load-balancer" {
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/AWSLoadBalancerControllerIAMPolicy"
  role       = "AmazonEKSLoadBalancerControllerRole"
  depends_on = [ aws_iam_policy.AWSLoadBalancerControllerIAMPolicy, aws_iam_role.AmazonEKSLoadBalancerControllerRole ]
}


resource "aws_iam_policy" "ExternalDNSIAMPolicy" {
  name        = "ExternalDNSIAMPolicy"
  description = "ExternalDNSIAMPolicy"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "route53:ChangeResourceRecordSets"
        ],
        "Resource": [
          "arn:aws:route53:::hostedzone/*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets"
        ],
        "Resource": [
          "*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "AmazonEKSExternalDNSRole" {
  name        = "AmazonEKSExternalDNSRole"
  description = "AmazonEKSExternalDNSRole"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "${data.terraform_remote_state.eks_remote_data.outputs.eks_cluster_oidc_arn}"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "${data.terraform_remote_state.eks_remote_data.outputs.eks_cluster_oidc}:aud": "sts.amazonaws.com",
            "${data.terraform_remote_state.eks_remote_data.outputs.eks_cluster_oidc}:sub": "system:serviceaccount:kube-system:external-dns"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy_externaldns" {
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/ExternalDNSIAMPolicy"
  role       = "AmazonEKSExternalDNSRole"
  depends_on = [ aws_iam_role.AmazonEKSExternalDNSRole, aws_iam_policy.ExternalDNSIAMPolicy ]
}

# #Load-balancer-controller-sa.yml
# resource "kubernetes_manifest" "load-balancer-controller-sa" {
#   manifest = {
#     apiVersion = "v1"
#     kind = "ServiceAccount"
#     metadata = {
#       labels = {
#         "app.kubernetes.io/component" = "controller"
#         "app.kubernetes.io/name" = "aws-load-balancer-controller"
#       }
#       name = "aws-load-balancer-controller"
#       namespace = "kube-system"
#       annotations = {
#         "eks.amazonaws.com/role-arn" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AmazonEKSLoadBalancerControllerRole"
#       }
#     }
#   }
#   depends_on = [ aws_iam_role_policy_attachment.attach_policy_load-balancer ]
# }

# #external-dns-sa.yml
# resource "kubernetes_manifest" "external-dns-sa" {
#   manifest = {
#       apiVersion = "v1"
#       kind       = "ServiceAccount"
#       metadata   = {
#         name      = "external-dns"
#         namespace = "kube-system"
#         annotations = {
#           "eks.amazonaws.com/role-arn" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AmazonEKSExternalDNSRole"
#         }
#       }
#   }
#   depends_on = [ aws_iam_role_policy_attachment.attach_policy_externaldns ]
# }

# resource "kubernetes_manifest" "external-dns-cluster-role" {
#   manifest = {
#     apiVersion = "rbac.authorization.k8s.io/v1"
#     kind       = "ClusterRole"
#     metadata   = {
#       name = "external-dns"
#     }
#     rules = [
#       {
#         apiGroups = [""]
#         resources = ["nodes"]
#         verbs     = ["watch", "list"]
#       },
#       {
#         apiGroups = [""]
#         resources = ["pods"]
#         verbs     = ["get", "watch", "list"]
#       },
#       {
#         apiGroups = [""]
#         resources = ["services"]
#         verbs     = ["get", "watch", "list"]
#       },
#       {
#         apiGroups = [""]
#         resources = ["endpoints"]
#         verbs     = ["get", "watch", "list"]
#       },
#       {
#         apiGroups = ["extensions", "networking.k8s.io"]
#         resources = ["ingresses"]
#         verbs     = ["get", "watch", "list"]
#       },
#     ]
#   }
#   depends_on = [ kubernetes_manifest.external-dns-sa ]
# }

# resource "kubernetes_manifest" "external-dns-cluster-role-binding" {
#   manifest = {
#     apiVersion = "rbac.authorization.k8s.io/v1"
#     kind       = "ClusterRoleBinding"
#     metadata   = {
#       name = "external-dns-viewer"
#     }
#     subjects = [
#       {
#         kind      = "ServiceAccount"
#         name      = "external-dns"
#         namespace = "kube-system"
#       }
#     ]
#     roleRef = {
#       kind     = "ClusterRole"
#       apiGroup = "rbac.authorization.k8s.io"
#       name     = "external-dns"
#     }
#   }
#   depends_on = [ kubernetes_manifest.external-dns-cluster-role ]
# }

# resource "kubernetes_manifest" "external-dns-deployment" {
#   manifest = {
#     apiVersion = "apps/v1"
#     kind       = "Deployment"
#     metadata   = {
#       name      = "external-dns"
#       namespace = "kube-system"
#     }
#     spec = {
#       selector = {
#         matchLabels = {
#           app = "external-dns"
#         }
#       }
#       strategy = {
#         type = "Recreate"
#       }
#       template = {
#         metadata = {
#           labels = {
#             app = "external-dns"
#           }
#           annotations = {
#             "eks.amazonaws.com/role-arn" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AmazonEKSExternalDNSRole"
#           }
#         }
#         spec = {
#           serviceAccountName = "external-dns"
#           containers = [
#             {
#               name  = "external-dns"
#               image = "bitnami/external-dns:latest"
#               args  = [
#                 "--source=service",
#                 "--source=ingress",
#                 "--domain-filter=navie.world",
#                 "--provider=aws",
#                 "--policy=sync",
#                 "--aws-zone-type=public",
#                 "--registry=txt",
#                 "--txt-owner-id=Z03518782ZID7B9UV0FIB"
#               ]
#             }
#           ]
#         }
#       }
#     }
#   }
#   depends_on = [ kubernetes_manifest.external-dns-cluster-role-binding ]
# }

# #HPA metrics-server-sa
# resource "kubernetes_manifest" "metrics-server-sa" {
#   manifest = {
#     apiVersion = "v1"
#     kind       = "ServiceAccount"
#     metadata   = {
#       labels = {
#         k8s-app = "metrics-server"
#       }
#       name      = "metrics-server"
#       namespace = "kube-system"
#     }
#   }
# }

# resource "kubernetes_manifest" "cluster-role-aggregated-metrics-reader" {
#   manifest = {
#     apiVersion = "rbac.authorization.k8s.io/v1"
#     kind       = "ClusterRole"
#     metadata   = {
#       labels = {
#         k8s-app                                   = "metrics-server"
#         "rbac.authorization.k8s.io/aggregate-to-admin" = "true"
#         "rbac.authorization.k8s.io/aggregate-to-edit"  = "true"
#         "rbac.authorization.k8s.io/aggregate-to-view"  = "true"
#       }
#       name = "system:aggregated-metrics-reader"
#     }
#     rules = [{
#       apiGroups = ["metrics.k8s.io"]
#       resources = ["pods", "nodes"]
#       verbs     = ["get", "list", "watch"]
#     }]
#   }
# }

# resource "kubernetes_manifest" "cluster-role-metrics-server" {
#   manifest = {
#     apiVersion = "rbac.authorization.k8s.io/v1"
#     kind       = "ClusterRole"
#     metadata   = {
#       labels = {
#         k8s-app = "metrics-server"
#       }
#       name = "system:metrics-server"
#     }
#     rules = [
#       {
#         apiGroups = [""]
#         resources = ["nodes/metrics"]
#         verbs     = ["get"]
#       },
#       {
#         apiGroups = [""]
#         resources = ["pods", "nodes"]
#         verbs     = ["get", "list", "watch"]
#       }
#     ]
#   }
# }

# resource "kubernetes_manifest" "role-binding-metrics-server-auth-reader" {
#   manifest = {
#     apiVersion = "rbac.authorization.k8s.io/v1"
#     kind       = "RoleBinding"
#     metadata   = {
#       labels = {
#         k8s-app = "metrics-server"
#       }
#       name      = "metrics-server-auth-reader"
#       namespace = "kube-system"
#     }
#     roleRef = {
#       apiGroup = "rbac.authorization.k8s.io"
#       kind     = "Role"
#       name     = "extension-apiserver-authentication-reader"
#     }
#     subjects = [{
#       kind      = "ServiceAccount"
#       name      = "metrics-server"
#       namespace = "kube-system"
#     }]
#   }
# }

# resource "kubernetes_manifest" "cluster-role-binding-auth-delegator" {
#   manifest = {
#     apiVersion = "rbac.authorization.k8s.io/v1"
#     kind       = "ClusterRoleBinding"
#     metadata   = {
#       labels = {
#         k8s-app = "metrics-server"
#       }
#       name = "metrics-server:system:auth-delegator"
#     }
#     roleRef = {
#       apiGroup = "rbac.authorization.k8s.io"
#       kind     = "ClusterRole"
#       name     = "system:auth-delegator"
#     }
#     subjects = [{
#       kind      = "ServiceAccount"
#       name      = "metrics-server"
#       namespace = "kube-system"
#     }]
#   }
# }

# resource "kubernetes_manifest" "cluster-role-binding-metrics-server" {
#   manifest = {
#     apiVersion = "rbac.authorization.k8s.io/v1"
#     kind       = "ClusterRoleBinding"
#     metadata   = {
#       labels = {
#         k8s-app = "metrics-server"
#       }
#       name = "system:metrics-server"
#     }
#     roleRef = {
#       apiGroup = "rbac.authorization.k8s.io"
#       kind     = "ClusterRole"
#       name     = "system:metrics-server"
#     }
#     subjects = [{
#       kind      = "ServiceAccount"
#       name      = "metrics-server"
#       namespace = "kube-system"
#     }]
#   }
# }

# resource "kubernetes_manifest" "service-metrics-server" {
#   manifest = {
#     apiVersion = "v1"
#     kind       = "Service"
#     metadata   = {
#       labels = {
#         k8s-app = "metrics-server"
#       }
#       name      = "metrics-server"
#       namespace = "kube-system"
#     }
#     spec = {
#       ports = [{
#         name       = "https"
#         port       = 443
#         protocol   = "TCP"
#         targetPort = "https"
#       }]
#       selector = {
#         k8s-app = "metrics-server"
#       }
#     }
#   }
# }

# resource "kubernetes_manifest" "deployment-metrics-server" {
#   manifest = {
#     apiVersion = "apps/v1"
#     kind       = "Deployment"
#     metadata   = {
#       labels = {
#         k8s-app = "metrics-server"
#       }
#       name      = "metrics-server"
#       namespace = "kube-system"
#     }
#     spec = {
#       selector = {
#         matchLabels = {
#           k8s-app = "metrics-server"
#         }
#       }
#       strategy = {
#         rollingUpdate = {
#           maxUnavailable = 0
#         }
#       }
#       template = {
#         metadata = {
#           labels = {
#             k8s-app = "metrics-server"
#           }
#         }
#         spec = {
#           containers = [{
#             args = [
#               "--cert-dir=/tmp",
#               "--secure-port=4443",
#               "--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname",
#               "--kubelet-use-node-status-port",
#               "--metric-resolution=15s",
#             ]
#             image           = "registry.k8s.io/metrics-server/metrics-server:v0.6.4"
#             imagePullPolicy = "IfNotPresent"
#             livenessProbe = {
#               failureThreshold = 3
#               httpGet = {
#                 path   = "/livez"
#                 port   = 443
#                 scheme = "HTTPS"
#               }
#               periodSeconds = 10
#             }
#             name = "metrics-server"
#             ports = [{
#               containerPort = 4443
#               name          = "https"
#               protocol      = "TCP"
#             }]
#             readinessProbe = {
#               failureThreshold    = 3
#               httpGet = {
#                 path   = "/readyz"
#                 port   = 443
#                 scheme = "HTTPS"
#               }
#               initialDelaySeconds = 20
#               periodSeconds       = 10
#             }
#             resources = {
#               requests = {
#                 cpu    = "100m"
#                 memory = "200Mi"
#               }
#             }
#             securityContext = {
#               allowPrivilegeEscalation = false
#               readOnlyRootFilesystem   = true
#               runAsNonRoot             = true
#               runAsUser                = 1000
#             }
#             volumeMounts = [{
#               mountPath = "/tmp"
#               name      = "tmp-dir"
#             }]
#           }]
#           nodeSelector       = {
#             "kubernetes.io/os" = "linux"
#           }
#           priorityClassName  = "system-cluster-critical"
#           serviceAccountName = "metrics-server"
#           volumes            = [{
#             emptyDir = {}
#             name     = "tmp-dir"
#           }]
#         }
#       }
#     }
#   }
# }

# resource "kubernetes_manifest" "api-service-metrics" {
#   manifest = {
#     apiVersion = "apiregistration.k8s.io/v1"
#     kind       = "APIService"
#     metadata   = {
#       labels = {
#         k8s-app = "metrics-server"
#       }
#       name      = "v1beta1.metrics.k8s.io"
#     }
#     spec = {
#       group                 = "metrics.k8s.io"
#       groupPriorityMinimum = 100
#       insecureSkipTLSVerify = true
#       service = {
#         name      = "metrics-server"
#         namespace = "kube-system"
#       }
#       version         = "v1beta1"
#       versionPriority = 100
#     }
#   }
# }