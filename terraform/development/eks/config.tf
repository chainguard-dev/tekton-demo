terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.27.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}
