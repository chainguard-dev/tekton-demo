terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    chainguard = {
      # NB: This provider is currently not public
      source = "chainguard-dev/chainguard"
    }
  }
}

provider "chainguard" {
  console_api = "https://console-api.chainguard.dev"
}

provider "aws" {}

resource "chainguard_group" "root" {
  name        = "demo root"
  description = "root group for demo"
}

module "account_association" {
  source = "../.."

  aws_account_id      = data.aws_caller_identity.current.account_id
  enforce_domain_name = "chainguard.dev"
  enforce_group_id    = chainguard_group.root.id
}

data "aws_caller_identity" "current" {}

resource "chainguard_account_associations" "demo-chaingaurd-dev-binding" {
  group = chainguard_group.root.id
  amazon {
    account = data.aws_caller_identity.current.account_id
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  cluster_name    = "demo"
  cluster_version = "1.21"

  cluster_endpoint_public_access = true

  vpc_id     = "vpc-example"
  subnet_ids = ["subnet-aaaaaa"]

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    disk_size = 50
  }

  eks_managed_node_groups = {
    green = {
      min_size     = 1
      max_size     = 1
      desired_size = 1

      instance_types = ["t3.large"]
      capacity_type  = "SPOT"
    }
  }

  manage_aws_auth_configmap = true
  aws_auth_roles = [
    {
      rolearn  = module.account_association.agentless_role_arn
      username = "admin"
      groups = [
        "system:masters",
      ]
    }
  ]
}

resource "chainguard_cluster" "terraform-provider-demo" {
  parent_id = chainguard_group.root.id
  managed {
    provider = "eks"
    info {
      server                     = module.eks.cluster_endpoint
      certificate_authority_data = base64decode(module.eks.cluster_certificate_authority_data)
    }
  }
}
