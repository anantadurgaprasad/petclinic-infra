module "eks" {
  source                      = "git::https://github.com/anantadurgaprasad/aws-service-modules.git//EKS"
  environment                 = var.environment
  app_name                    = var.app_name
  eks_version                 = var.eks_version
  subnet_ids                  = module.vpc.public_subnets_id #module.vpc.private_subnets_id
  eks_instance_type           = var.eks_instance_type
  eks_desired_size            = var.eks_desired_size
  eks_min_size                = var.eks_min_size
  eks_max_size                = var.eks_max_size
  eks_endpoint_private_access = var.eks_endpoint_private_access
  eks_endpoint_public_access  = var.eks_endpoint_public_access
  depends_on                  = [module.vpc]
}
provider "kubernetes" {
  host                   = module.eks.endpoint
  cluster_ca_certificate = base64decode(module.eks.eks_cluster_cert_authority)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks.eks_cluster_name, "--profile", "personal-aws"]
    command     = "aws"
  }
  alias = "eks"
}
/*=====
Managing aws-auth config map
=======*/
locals {
  aws_auth_configmap_data = {
    mapRoles    = yamlencode(local.aws_auth_roles)
    mapUsers    = yamlencode(local.aws_auth_users)
    mapAccounts = yamlencode(local.aws_auth_accounts)
  }
  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::755754929567:role/dev-petclinic-eks-admin-access-role"
      username = "adminrole"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "${module.eks.eks_node_iam_role_arn}"
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    }
  ]
  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::755754929567:user/DurgaAd"
      username = "DurgaAd"
      groups   = ["system:masters"]
    }
  ]
  aws_auth_accounts = []
}
resource "kubernetes_config_map_v1_data" "aws_auth" {

  force = true

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data       = local.aws_auth_configmap_data
  depends_on = [module.eks]
  provider   = kubernetes.eks
}

/*==========
Register the Cluster
=============*/
provider "argocd" {
  server_addr = "k8s-argocd-argocdse-2ebe349daf-235284030.us-west-2.elb.amazonaws.com:80"
  insecure    = true
  username    = "admin"
  password    = "OV2bFg4x7FrjkZuZ"
  plain_text  = true
}

module "register_cluster" {
  source = "git::https://github.com/anantadurgaprasad/aws-service-modules.git//ArgoCDClusterConnect"

  cluster_endpoint                   = module.eks.endpoint
  cluster_name                       = module.eks.eks_cluster_name
  cluster_certificate_authority_data = module.eks.eks_cluster_cert_authority
  argocd_management_role_arn         = module.argocd_irsa.role_arn
}


# module "controller" {
#   source                   = "git::https://github.com/anantadurgaprasad/aws-service-modules.git//AWSALBController"
#   oidc_url = module.eks.oidc_url
#   cluster_name = module.eks.eks_cluster_name
#   namespace = var.namespace
#   service_account = var.service_account
#   controller_version = var.controller_version
#   app_name = var.app_name
#   environment = var.environment

# }

# module "irsa" {
#   source        = "git::https://github.com/anantadurgaprasad/aws-service-modules.git//IRSA"
#   oidc_provider = replace(module.eks.oidc_url, "https://", "")

#   namespace       = "kube-system"
#   service_account = "aws-alb-controller-sa"
#   role_name       = "${var.environment}-${var.app_name}-irsa"
#   policy_arns     = ["arn:aws:iam::aws:policy/AdministratorAccess"]
#   depends_on = [ module.eks ]
# }

# resource "helm_release" "aws_alb_controller" {
#   name       = "aws-load-balancer-controller"

#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"
#   namespace = "kube-system"
#   timeout                    = 600
#   cleanup_on_fail = true
#   values = [
#     templatefile("./values.yaml.tftpl",{
#       annotations = {"eks.amazonaws.com/role-arn" = "${module.irsa.role_arn}"},
#       serviceaccount_name = "aws-alb-controller-sa",
#       cluster_name = "${module.eks.eks_cluster_name}"

#     })

#   ]
#   # set {
#   #   name = "region"
#   #   value = "${var.region}"
#   # }
#   # set {
#   #   name = "VpcId"
#   #   value = "${module.vpc.vpc_id}"
#   # }

#   depends_on = [ time_sleep.wait_60_seconds ]
# }
