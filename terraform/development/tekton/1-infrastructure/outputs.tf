

// Bastion outputs
output "ssh_cmd" {
  description = "Instructions to connect to bastion"
  value       = "gcloud compute ssh --zone ${module.bastion.zone} ${module.bastion.name} --tunnel-through-iap --project ${module.bastion.project}"
}

output "bastion_name" {
  value = module.bastion.name
}

output "bastion_zone" {
  value = module.bastion.zone
}

output "bastion_project" {
  value = module.bastion.project
}

output "ip_address" {
  description = "private IP address of bastion"
  value       = module.bastion.ip_address
}

output "bastion_socks_proxy_setup" {
  description = "Gcloud compute ssh to the bastion host command"
  value       = "${module.bastion.ssh_cmd} -- -N -D 8118"
}

output "bastion_kubectl" {
  description = "kubectl command using the local proxy once the bastion_ssh command is running"
  value       = "HTTPS_PROXY=socks5://localhost:8118 kubectl get pods --all-namespaces"
}

// Cluster outputs
output "cluster_name" {
  description = "Convenience output to obtain the GKE Cluster name"
  value       = module.cluster.cluster_name
}

output "cluster_endpoint" {
  description = "Cluster endpoint"
  value       = module.cluster.cluster_endpoint
}

output "cluster_ca_certificate" {
  sensitive   = true
  description = "Cluster ca certificate (base64 encoded)"
  value       = module.cluster.cluster_ca_certificate
}

output "get_credentials" {
  description = "Gcloud get-credentials command"
  value       = module.cluster.get_credentials
}

output "gke_sa_email" {
  value = module.cluster.gke_sa_email
}

output "ca_certificate" {
  value = module.cluster.ca_certificate
}


