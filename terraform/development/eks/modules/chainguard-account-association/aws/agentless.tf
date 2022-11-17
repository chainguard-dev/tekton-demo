// This defines a role without permissions in IAM, but which should be authorized
// to manage clusters via:
//   eksctl create iamidentitymapping --cluster  <clusterName> --region=<region> \
//        --arn arn:aws:iam::${TF_VAR_ACCOUNT_ID}:role/chainguard-agentless \
//        --group system:masters --username admin
resource "aws_iam_role" "agentless_role" {
  name = "chainguard-agentless"
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
          // This role may only be impersonated by Chainguard's "agentless"
          // components, which mints tokens suitable for talking to EKS
          // clusters.  We are authorizing components nested under GROUP
          // to perform this impersonation.
          "issuer.${var.enforce_domain_name}:sub" : "agentless:${var.enforce_group_id}"
          // Tokens must be intended for use with Amazon.
          "issuer.${var.enforce_domain_name}:aud" : "amazon"
        }
      }
    }]
  })
}

// Our agentless roles need describe/list to look up cluster names from
// the EKS endpoints they are provided.  As our managed agents start up
// they will look up the cluster-name based on this endpoint, and then
// use that cluster-name to authenticate with the cluster.
// This policy is based on this sample:
// https://docs.aws.amazon.com/eks/latest/userguide/security_iam_id-based-policy-examples.html#policy_example2
resource "aws_iam_policy" "eks_read_policy" {
  name        = "chainguard-eks-read-policy"
  description = "A policy to allow Chainguard to list and describe EKS clusters."
  policy      = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "eks:DescribeCluster",
            "eks:ListClusters"
          ],
          "Resource": "*"
        }
      ]
    }
  EOF
}

// The permissions to grant the "agentless" role.
resource "aws_iam_role_policy_attachment" "agentless_eks_read" {
  role       = aws_iam_role.agentless_role.name
  policy_arn = aws_iam_policy.eks_read_policy.arn
}
