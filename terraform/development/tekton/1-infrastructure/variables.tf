

variable "network_name" {
  default     = "tekton-ci-network"
  type        = string
  description = "Name of the network to deploy too"
}

variable "subnetwork_name" {
  default     = "tekton-ci-subnet"
  type        = string
  description = "Name of the subnetwork to deploy too"
}

variable "project_id" {
  type = string
  validation {
    condition     = length(var.project_id) > 0
    error_message = "Must specify project_id variable."
  }
}

variable "project_number" {
  type        = number
  description = "Project number associated with project_id"
}

// Optional values that can be overridden or appended to if desired.
variable "cluster_name" {
  description = "The name to give the new Kubernetes cluster."
  type        = string
  default     = "tekton"
}

variable "env" {
  description = "environment for deployment"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "The region in which to create the VPC network"
  type        = string
}

variable "cluster_zone" {
  description = "The zone in which to create the k8s cluster"
  type        = string
  default     = "us-central1-a"
}

variable "github_repo" {
  description = "Github repo for running Github Actions from."
  type        = string
  default     = "chainguard-dev/tekton-demo"
}

// We don't actually need this but it's required by the bastion module
// So just assign it to the github-actions SA, which already has the permissions that will be granted
// in the bastion module
variable "tunnel_accessor_sa" {
  type        = string
  description = "Email of group to give access to the tunnel to"
  default     = "serviceAccount:github-actions@customer-engineering-357819.iam.gserviceaccount.com"
}



// CLUSTER DATABASE ENCRYPTION
variable "database_encryption_state" {
  type    = string
  default = "ENCRYPTED"
}

variable "database_encryption_key_name" {
  type    = string
  default = "projects/customer-engineering-357819/locations/global/keyRings/gke-secrets/cryptoKeys/tekton-dev"
}

variable "autoscaling_min_node" {
  type    = number
  default = 3
}

variable "autoscaling_max_node" {
  type    = number
  default = 5
}


variable "cluster_network_tag" {
  type    = string
  default = ""
}
