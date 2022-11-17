output "agentless_role_arn" {
  value       = aws_iam_role.agentless_role.arn
  description = <<-EOF
    This defines a role without permissions in IAM, but which should be authorized
    to manage clusters via:
     eksctl create iamidentitymapping --cluster  <clusterName> --region=<region> \
          --arn << agenless_role_arn >> \
          --group system:masters --username admin
  EOF
}
