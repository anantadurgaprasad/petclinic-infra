module "argocd_eks" {
  source                      = "git::https://github.com/anantadurgaprasad/aws-service-modules.git//EKS"
  environment                 = var.environment
  app_name                    = "argocd"
  eks_version                 = var.eks_version
  subnet_ids                  = module.vpc.public_subnets_id
  eks_instance_type           = var.eks_instance_type
  eks_desired_size            = var.eks_desired_size
  eks_min_size                = var.eks_min_size
  eks_max_size                = var.eks_max_size
  eks_endpoint_private_access = var.eks_endpoint_private_access
  eks_endpoint_public_access  = var.eks_endpoint_public_access
  depends_on                  = [module.vpc]
}
provider "helm" {
  kubernetes {
    host                   = module.argocd_eks.endpoint
    cluster_ca_certificate = base64decode(module.argocd_eks.eks_cluster_cert_authority)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.argocd_eks.eks_cluster_name, "--profile", "personal-aws"]
      command     = "aws"


    }

  }


}
module "controller" {
  source               = "git::https://github.com/anantadurgaprasad/aws-service-modules.git//AWSALBController"
  oidc_url             = module.argocd_eks.oidc_url
  cluster_name         = module.argocd_eks.eks_cluster_name
  namespace            = var.namespace
  service_account      = var.service_account
  irsa_service_account = ["system:serviceaccount:${var.namespace}:${var.service_account}"]
  controller_version   = var.controller_version
  app_name             = "argocd"
  environment          = var.environment
  depends_on           = [module.argocd_eks]
}

resource "helm_release" "argocd" {
  name = "argocd"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  timeout          = 600
  version          = "7.7.7"
  cleanup_on_fail  = true
  values           = [file("./values.yaml")]
  depends_on       = [module.controller]
  set {
    name  = "server.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.argocd_irsa.role_arn
  }
  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.argocd_irsa.role_arn
  }
}

/*==========
ArgoCD assume role
==========*/
module "argocd_irsa" {
  source        = "git::https://github.com/anantadurgaprasad/aws-service-modules.git//IRSA"
  oidc_provider = replace(module.argocd_eks.oidc_url, "https://", "")


  service_account = ["system:serviceaccount:argocd:argocd-server", "system:serviceaccount:argocd:argocd-application-controller"]
  role_name       = "${module.argocd_eks.eks_cluster_name}-argocd-assume-role"
  policy_arns     = []

}

/*============
Register new cluster
================*/
# provider "kubectl" {
#   host                   = module.argocd_eks.endpoint
#     cluster_ca_certificate = base64decode(module.argocd_eks.eks_cluster_cert_authority)
#     exec {
#       api_version = "client.authentication.k8s.io/v1beta1"
#       args        = ["eks", "get-token", "--cluster-name", module.argocd_eks.eks_cluster_name, "--profile", "personal-aws"]
#       command     = "aws"


#     }

# }

# resource "kubectl_manifest" "my_service" {
#     yaml_body = templatefile("${path.module}/cluster-connect.yaml.tfpl", {
#       cluster_name = module.eks.eks_cluster_name,
#       cluster_url = module.eks.endpoint,
#       role_arn = "arn:aws:iam::755754929567:role/dev-petclinic-eks-admin-access-role"
#       base64_cert = module.eks.eks_cluster_cert_authority
#     })

# }
