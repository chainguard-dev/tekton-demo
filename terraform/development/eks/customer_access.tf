variable "CUSTOMER_ROLE" {
  description = "Across account role that the customer is using"
}
resource "aws_iam_role" "customer_access" {
  name = "${var.CUSTOMER_NAME}-access-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${var.CUSTOMER_ACCOUNT_ID}:root"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

}

resource "aws_iam_role" "customer_access_test" {
  name = "cg-${var.CUSTOMER_NAME}-dev-test-access-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::452336408843:root"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

}

resource "aws_iam_role_policy_attachment" "test" {
  policy_arn = aws_iam_policy.customer_access.arn
  role       = aws_iam_role.customer_access_test.name
}

resource "aws_iam_role_policy_attachment" "customer_access" {
  policy_arn = aws_iam_policy.customer_access.arn
  role       = aws_iam_role.customer_access.name
}


resource "aws_iam_policy" "customer_access" {

  name = "${var.CUSTOMER_NAME}-access-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "eks:ListNodegroups",
          "eks:DescribeFargateProfile",
          "eks:ListTagsForResource",
          "eks:ListAddons",
          "eks:DescribeAddon",
          "eks:ListFargateProfiles",
          "eks:DescribeNodegroup",
          "eks:DescribeIdentityProviderConfig",
          "eks:ListUpdates",
          "eks:DescribeUpdate",
          "eks:AccessKubernetesApi",
          "eks:DescribeCluster",
          "eks:ListIdentityProviderConfigs",
          "eks:ListClusters",
          "eks:DescribeAddonVersions",
          "eks:RegisterCluster",
          "eks:CreateCluster"
        ],
        "Resource" : [module.eks.cluster_arn]
      },
      {
        "Sid" : "VisualEditor1",
        "Effect" : "Allow",
        "Action" : "sts:AssumeRole"
        "Resource" : aws_iam_role.customer_access.arn
      }
    ]
  })
}
