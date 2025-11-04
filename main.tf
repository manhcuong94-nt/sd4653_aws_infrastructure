terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.63.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.15.0"
    }
  }
}

provider "aws" {
  region  = "ap-southeast-1"
  default_tags {
    tags = {
      Course = "Pratical DevOps"
    }
  }
}

# Virtual network
resource "aws_vpc" "msavnet" {
  cidr_block = var.vnet_cidr_block
  enable_dns_hostnames = true
  enable_dns_support = true
  tags       = var.vpc_tags
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidr)

  vpc_id                                      = aws_vpc.msavnet.id
  cidr_block                                  = var.public_subnet_cidr[count.index]
  map_public_ip_on_launch                     = true
  enable_resource_name_dns_a_record_on_launch = true
  availability_zone                           = var.subnet_azs[count.index]
  tags                                        = var.public_subnet_tags
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidr)

  vpc_id     = aws_vpc.msavnet.id
  cidr_block = var.private_subnet_cidr[count.index]
  availability_zone = var.subnet_azs[count.index]
  tags       = var.private_subnet_tags
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.msavnet.id
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.msavnet.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}
resource "aws_route_table_association" "public_internet" {
  count = length(var.public_subnet_cidr)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.this.id
}

# resource "aws_network_acl" "internet_acl" {
#   vpc_id     = aws_vpc.msavnet.id
#   subnet_ids = [for subnet in aws_subnet.public: subnet.id]

#   dynamic "ingress" {
#     for_each = var.public_acl_ingress
#     content {
#       from_port  = ingress.value["from_port"]
#       to_port    = ingress.value["to_port"]
#       rule_no    = ingress.value["rule_no"]
#       action     = ingress.value["action"]
#       protocol   = ingress.value["protocol"]
#       cidr_block = ingress.value["cidr_block"]
#     }
#   }

#   egress {
#     from_port  = 0
#     to_port    = 0
#     rule_no    = 100
#     action     = "allow"
#     protocol   = -1
#     cidr_block = "0.0.0.0/0"
#   }
# }

resource "aws_ecr_repository" "backend" {
  name = "ntg-garage-backend"
}
resource "aws_ecr_repository" "frontend" {
  name = "ntg-garage-frontend"
}

# EKS cluster
# Policy AmazonEKSClusterPolicy, AmazonEKSVPCResourceController
data "aws_iam_role" "eks_service_role" {
  name = "AmazonEKSClusterRole"
}

resource "aws_eks_cluster" "this" {
  name = var.eks_cluster_name
  role_arn = data.aws_iam_role.eks_service_role.arn
  vpc_config {
    subnet_ids = aws_subnet.public.*.id 
    public_access_cidrs = var.eks_public_access_cidrs
  }
}

# resource "aws_eks_addon" "this" {
#  count = length(local.eks_add_ons)

#  cluster_name = aws_eks_cluster.this.name
#  addon_name = local.eks_add_ons[count.index]
#}

# Policy AmazonEC2ContainerRegistryReadOnly, AmazonEKS_CNI_Policy, AmazonEKSWorkerNodePolicy
data "aws_iam_role" "eks_worker_role" {
  name = "AmazonEKSWorkerRole"
}
resource "aws_eks_node_group" "this" {
  cluster_name  = aws_eks_cluster.this.name
  node_group_name = "practicaldevops-nodegroup"
  node_role_arn = data.aws_iam_role.eks_worker_role.arn
  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 0
  }
  subnet_ids     = aws_subnet.public.*.id
  ami_type       = "AL2023_x86_64_STANDARD"
  disk_size      = 8
  capacity_type  = "SPOT"
  instance_types = ["t3.medium"]
}

# resource "helm_release" "prometheus" {
#   name = "prometheus"
#   chart = "prometheus"
#   repository = "https://prometheus-community.github.io/helm-charts"
#   namespace = "prometheus"
#   create_namespace = true
#   cleanup_on_fail = true

#   dynamic "set" {
#     for_each = var.prometheus_chart_values
    
#     iterator = chart_value
#     content {
#       name = chart_value.value["name"]
#       value = chart_value.value["value"]
#     }
#   }

#   depends_on = [ aws_eks_node_group.this ]
# }

# resource "helm_release" "grafana" {
#   name = "grafana"
#   chart = "grafana"
#   repository = "https://grafana.github.io/helm-charts"
#   namespace = "grafana"
#   create_namespace = true
#   cleanup_on_fail = true

#   dynamic "set" {
#     for_each = var.grafana_chart_values
#     iterator = chart_value
#     content {
#       name = chart_value.value["name"]
#       value = chart_value.value["value"]
#     }
#   }

#   depends_on = [ aws_eks_node_group.this ]
# }