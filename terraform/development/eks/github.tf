# https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services

variable "GITHUB_URL" {
  type        = string
  description = "github url for OIDC"
  default     = "token.actions.githubusercontent.com"
}
#
#resource "aws_iam_openid_connect_provider" "github" {
#
#  url = "https://${var.GITHUB_URL}"
#
#  client_id_list = ["sts.amazonaws.com"]
#
#
#  # https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc_verify-thumbprint.html
#  thumbprint_list = ["15e29108718111e59b3dad31954647e3c344a231"]
#
#}
#
#data "external" "thumbprint" {
#  program = ["bash", "./thumbprint.sh", var.GITHUB_URL]
#}

data "aws_iam_openid_connect_provider" "github"{
  url = "https://${var.GITHUB_URL}"
}
# Role for github
variable "GITHUB_REPO" {
  type        = string
  description = "Project inside github that is making requests to AWS"
  default     = "chainguard-dev/tekton-demo"
}

resource "aws_iam_role" "github_role" {
  name = "${var.CUSTOMER_NAME}-github-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : data.aws_iam_openid_connect_provider.github.arn
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${data.aws_iam_openid_connect_provider.github.url}:sub" : "repo:${var.GITHUB_REPO}:ref:refs/heads/main",
            "${data.aws_iam_openid_connect_provider.github.url}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "github_role" {

  name = "${var.CUSTOMER_NAME}-github-role-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Admin",
        "Effect" : "Allow",
        "Action" : [
          "*"
        ],
        "Resource" : "*"
      }
    ]
  })

  role = aws_iam_role.github_role.id
}
