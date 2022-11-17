// This configures a Chainguard environment's OIDC issuer as an Identity
// Provider (IdP), and allows the list of audiences specified via AUDIENCE.
resource "aws_iam_openid_connect_provider" "chainguard_idp" {
  url            = "https://issuer.${var.enforce_domain_name}"
  client_id_list = ["amazon"]

  # AWS wants the thumbprint of the root certificate that was used as our CA.
  # This is not easily scripted, so hard-coding this seems preferable.  Follow
  # the AWS documentation for producing thumbprint if this does not work.
  thumbprint_list = [
    # ISRG root certificate (LetsEncrypt) 
    "933c6ddee95c9c41a40f9f50493d82be03ad87bf",
    # GlobalSign root certificate (Google Managed Certficates) 
    "08745487e891c19e3078c1f2a07e452950ef36f6"
  ]
}

resource "aws_iam_role" "canary_role" {
  // Canary role has no permissions, but is used to validate that AWS account
  // connection has been correctly set up.
  name = "chainguard-canary"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Principal" : {
        "Federated" : aws_iam_openid_connect_provider.chainguard_idp.arn
      },
      "Action" : "sts:AssumeRoleWithWebIdentity",
      "Condition" : {
        "StringEquals" : {
          // This role may only be impersonated by Chainguard's "canary"
          // component, which mints tokens suitable for testing.  We are
          // authorizing components nested under GROUP to perform this
          // impersonation.
          "issuer.${var.enforce_domain_name}:sub" : "canary:${var.enforce_group_id}"
          // Tokens must be intended for use with Amazon.
          "issuer.${var.enforce_domain_name}:aud" : "amazon"
        }
      }
    }]
  })
}
