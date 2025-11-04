variable "vnet_cidr_block" {
  type        = string
  description = "The IPv4 CIDR block for the VPC."
}

variable "vpc_tags" {
  type        = map(string)
  default     = {}
  description = "(Optional) A map of tags to assign to the resource."
}

variable "public_subnet_cidr" {
  type        = list(string)
  default     = ["10.0.128.0/20", "10.0.64.0/20"]
  description = "(Optional) The IPv4 CIDR block for the public subnet."
}

variable "private_subnet_cidr" {
  type        = list(string)
  default     = []
  description = "(Optional) The IPv4 CIDR block for the private subnet."
}

variable "subnet_azs" {
  type = list(string)
  default = ["ap-southeast-1a", "ap-southeast-1b"]
  description = "(Optional) AZ for the subnet."
}

variable "public_subnet_tags" {
  type        = map(string)
  default     = {}
  description = "(Optional) A map of tags to assign to the resource."
}

variable "private_subnet_tags" {
  type        = map(string)
  default     = {}
  description = "(Optional) A map of tags to assign to the resource."
}

# variable "ssh_key_name" {
#   type        = string
#   description = "(Optional) The name for the key pair. If neither key_name nor key_name_prefix is provided, Terraform will create a unique key name using the prefix terraform-."
# }

# variable "public_key" {
#   type        = string
#   description = "(Required) The public key material"
# }

variable "public_acl_ingress" {
  type        = list(map(string))
  default     = []
  description = "(Optional) Specifies an ingress rule."
}

# variable "root_volume_size" {
#   type        = number
#   default     = null
#   description = "(Optional) Size of the volume in gibibytes (GiB)."
# }

# variable "ami" {
#   type        = string
#   description = "AMI to use for the instance."
# }

# variable "sg_ingress" {
#   type        = list(map(string))
#   default     = []
#   description = "(Optional) Specifies an ingress rule."
# }

variable "eks_cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "eks_public_access_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "(Optional) List of CIDR blocks. Indicates which CIDR blocks can access the Amazon EKS public API server endpoint when enabled. EKS defaults this to a list with 0.0.0.0/0"
}

variable "grafana_chart_values" {
  type        = list(map(string))
  default     = []
  description = "(Optional) List of custom values for Grafana Helm release"
}

variable "prometheus_chart_values" {
  type        = list(map(string))
  default     = []
  description = "(Optional) List of custom values for Prometheus Helm release"
}

locals {
  eks_add_ons = ["kube-proxy", "vpc-cni", "coredns"]
}