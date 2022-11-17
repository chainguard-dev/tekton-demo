# Terraform AWS Chainguard Account Association Module

Terraform module to connect Chainguard to your AWS Account.

This module is needed if you're using [Chainguard
Enforce](https://www.chainguard.dev/chainguard-enforce) and:

- Your containers (along with potential signatures and SBOMs etc) are in
a private AWS ECR registry
- Your signatures are created via AWS KMS
- Your using managed (i.e agentless) clusters in EKS

## Usage

This module binds an Enforce IAM group to an AWS account. To set up the connect
in Enforce using the CLI run:

```
export ENFORCE_GROUP_ID="<<uidp of target Enforce IAM group>>
export AWS_ACCOUNT_ID="12 digit AWS account ID to connect to"

chainctl iam group set-aws $ENFORCE_GROUP_ID --account $AWS_ACCOUNT_ID
```

Or using our (soon to be released publically) Terraform provider

```Terraform
resource "chainguard_account_associations" "example" {
  group = "<< enforce group id>>"
  amazon {
    account = "<< 12 digit account id>>"
  } 
}
```

To configured the connection on AWS side use this module as follows:

```Terraform


module "chainguard-account-association" {
  source = "chainguard-dev/chainguard-account-association/aws"

  enforce_group_id = "<< enforce group id>>"
}
```

## How does it work?

Chainguard Enforce has an OIDC identity provider. This module configured your
AWS account to recognize that OIDC identity provider and allows certain tokens
to bind to certain AWS IAM roles. In particular it allows:

- Our policy controller to bind to a role that gives us read access to your ECR
  registry to check signatures
- Our policy controller public key read access to your KMS keys to validate KMS
  signatures
- Our agentless controller to list and describe EKS clusters if using managed
  clusters

This access is restricted to clusters and policies you've configured at or
below the scope of the Enforce group you configure.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 2.7.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_openid_connect_provider.chainguard_idp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_policy.eks_read_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.agentless_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.canary_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.cosigned_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.agentless_eks_read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cosigned_ecr_read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cosigned_kms_pki_read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enforce_domain_name"></a> [enforce\_domain\_name](#input\_enforce\_domain\_name) | Domain name of your Chainguard Enforce environment | `string` | `"guak.dev"` | no |
| <a name="input_enforce_group_id"></a> [enforce\_group\_id](#input\_enforce\_group\_id) | Enforce IAM group ID to bind your AWS account to | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_agentless_role_arn"></a> [agentless\_role\_arn](#output\_agentless\_role\_arn) | This defines a role without permissions in IAM, but which should be authorized<br>to manage clusters via:<br> eksctl create iamidentitymapping --cluster  <clusterName> --region=<region> \<br>      --arn << agenless\_role\_arn >> \<br>      --group system:masters --username admin |
<!-- END_TF_DOCS -->
