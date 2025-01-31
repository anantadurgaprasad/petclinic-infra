variable "region" {
  type        = string
  description = "AWS Region to Deploy code"
}

variable "cidr_base" {
  type        = string
  description = "VPC CIDR"
}
variable "public_subnets" {
  type        = list(string)
  description = "list of public subnet ids"
}
variable "private_subnets" {
  type        = list(string)
  description = "list of private subnet ids"
}
variable "environment" {
  type        = string
  description = "Environment name used in prefix"
}

variable "app_name" {
  type        = string
  description = "Application name used in prefix"
}
variable "create_nat" {
  type        = bool
  description = "Boolean to create nat gateway or not"
}

/*=========
EKS module variables
==========*/

variable "eks_endpoint_private_access" {
  type        = bool
  description = "Boolean to keep EKS endpoint private"

}
variable "eks_endpoint_public_access" {
  type        = bool
  description = "Boolean to keep EKS endpoint public"
}
variable "eks_version" {
  type        = string
  description = "EKS version"
}

variable "eks_instance_type" {
  type        = string
  description = "EKS nodes instance type"
}

variable "eks_desired_size" {
  type        = number
  description = "Desired number of EKS nodes"
}
variable "eks_min_size" {
  type        = number
  description = "Minimum number of EKS nodes"
}
variable "eks_max_size" {
  type        = number
  description = "Maximum number of EKS Nodes"
}
/*========
AWS ALB Controller Version
=======*/
variable "namespace" {
  type        = string
  description = "Namespace to which Controller will be deployed"
}
variable "service_account" {
  type        = string
  description = "Service Account name associated to the controller pod"
}
variable "controller_version" {
  type        = string
  description = "Helm Chart version of the AWS ALB Controller"
}
