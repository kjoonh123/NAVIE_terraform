terraform {
  backend "s3" {
    bucket         = "navie-bucket-state-navie-web-project"
    key            = "aws_terraform/navie_eks_resource.tfstate"
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

provider "helm" {
  kubernetes {
    config_path = "~/.kube/kubeconfig"
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/kubeconfig"
  config_context = "navie-eks"
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = "navie-eks"
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
}


resource "kubernetes_manifest" "namespace_navie" {
  manifest = {
    apiVersion = "v1"
    kind = "Namespace"
    metadata = {
      labels = {
        name = "navie"
      }
      name = "navie"
    }
  }
}

resource "kubernetes_manifest" "navie-web-service" {
  manifest = {
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = "navie-svc"
      labels    = {
        app     = "navie-app"
        project = "navie"
      }
      namespace = "navie"
    }
    spec = {
      type = "NodePort"
      selector = {
        app = "navie-app"
      }
      ports = [
        {
          port        = 80
          targetPort  = 80
        }
      ]
    }
  }
  depends_on = [ kubernetes_manifest.namespace_navie ]
}

resource "kubernetes_manifest" "navie-deploy" {
  manifest = {
    apiVersion = "apps/v1"
    kind       = "Deployment"
    metadata = {
      name      = "navie-deploy"
      labels    = {
        app     = "navie-app"
        project = "navie"
      }
      namespace = "navie"
    }
    spec = {
      replicas = 4
      selector = {
        matchLabels = {
          app = "navie-app"
        }
      }
      template = {
        metadata = {
          labels = {
            app = "navie-app"
          }
        }
        spec = {
          containers = [
            {
              name  = "navie-app"
              image = "kjoonh/navie:v1.4.0"
              ports = [
                {
                  containerPort = 80
                },
                {
                  containerPort = 3306
                }
              ]
              resources = {
                limits = {
                  memory = "500Mi"
                  cpu    = "500m"
                }
              }
              livenessProbe = {
                httpGet = {
                  path   = "/"
                  port   = 80
                }
                initialDelaySeconds = 60
                periodSeconds       = 3
                successThreshold    = 1
                failureThreshold    = 3
                timeoutSeconds      = 10
              }
            }
          ]
        }
      }
      strategy = {
        type = "RollingUpdate"
        rollingUpdate = {
          maxSurge       = 2
          maxUnavailable = 1
        }
      }
    }
  }
  depends_on = [kubernetes_manifest.namespace_navie]
}

resource "kubernetes_manifest" "autoscaling" {
  manifest = {
    apiVersion = "autoscaling/v2"
    kind       = "HorizontalPodAutoscaler"
    metadata = {
      name      = "my-hpa"
      namespace = "navie"
    }
    spec = {
      scaleTargetRef = {
        apiVersion = "apps/v1"
        kind       = "Deployment"
        name       = "navie-deploy"
      }
      minReplicas = 1
      maxReplicas = 5
      metrics = [{
        type = "Resource"
        resource = {
          name   = "cpu"
          target = {
            type              = "Utilization"
            averageUtilization = 80
          }
        }
      }]
    }
  }
  depends_on = [ kubernetes_manifest.namespace_navie, kubernetes_manifest.navie-deploy ]
}

resource "kubernetes_manifest" "ingress-navie" {
  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"
    metadata = {
      name      = "navie-ingress"
      namespace = "navie"
      annotations = {
        "alb.ingress.kubernetes.io/load-balancer-name" = "navie-eks-alb"
        "alb.ingress.kubernetes.io/scheme"            = "internet-facing"
        "alb.ingress.kubernetes.io/target-type"       = "ip"
        "alb.ingress.kubernetes.io/stickiness-enabled" = "true"
        "alb.ingress.kubernetes.io/target-group-attributes" = "stickiness.enabled=true,stickiness.lb_cookie.duration_seconds=300"
        "external-dns.alpha.kubernetes.io/hostname"   = "navie.world"
      }
    }
    spec = {
      ingressClassName = "alb"
      defaultBackend = {
        service = {
          name = "navie-svc"
          port = {
            number = 80
          }
        }
      }
      rules = [
        {
          host = "www.navie.world"
          http = {
            paths = [
              {
                pathType = "Prefix"
                path     = "/"
                backend = {
                  service = {
                    name = "navie-svc"
                    port = {
                      number = 80
                    }
                  }
                }
              }
            ]
          }
        }
      ]
    }
  }
  depends_on = [ helm_release.aws_load_balancer_controller, kubernetes_manifest.namespace_navie, kubernetes_manifest.autoscaling ]
}