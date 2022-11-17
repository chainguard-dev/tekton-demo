provider "aws" {
  region = local.region

  default_tags {
    tags = {
      project  = "tekton-demo"
      Owner    = var.OWNER
      Customer = var.CUSTOMER_NAME
      source   = "https://github.com/chainguard-dev/tekton-dev"
    }
  }
}

locals {
  name            = "${var.CUSTOMER_NAME}-pov"
  cluster_version = "1.23"
  region          = var.DEFAULT_LOCATION
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1"
    args        = ["eks", "get-token", "--cluster-name", local.name]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1"
      args        = ["eks", "get-token", "--cluster-name", local.name]
      command     = "aws"
    }
  }
}

#provider "chainguard" {
#  console_api = var.CONSOLE_URL
#}
