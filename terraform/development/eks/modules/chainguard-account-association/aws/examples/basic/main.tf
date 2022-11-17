terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
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
