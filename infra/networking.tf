module "vpc" {
  source          = "git::https://github.com/anantadurgaprasad/aws-service-modules.git//vpc"
  environment     = var.environment
  app_name        = var.app_name
  cidr_base       = var.cidr_base
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  create_nat      = var.create_nat
}