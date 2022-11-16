variable "project_id" {
  type = string
  validation {
    condition     = length(var.project_id) > 0
    error_message = "Must specify project_id variable."
  }
}

variable "region" {
  description = "The region in which to create the VPC network"
  type        = string
}

// Optional values that can be overridden or appended to if desired.
variable "cluster_name" {
  description = "The name to give the new Kubernetes cluster."
  type        = string
  default     = "tekton-dev"
}

variable "cluster_zone" {
  type    = string
  default = "us-central1-a"
}

// External secrets variables

variable "external_secrets_chart_version" {
  description = "Version of External-Secrets Helm chart. Versions listed here https://artifacthub.io/packages/helm/external-secrets-operator/external-secrets"
  type        = string
  default     = "0.5.5"
}

variable "github_repo" {
  description = "Github repo for running Github Actions from."
  type        = string
  default     = "chainguard-dev/tekton-demo"
}

variable "tekton_chains_sa_name" {
  default     = "tekton-chains-controller"
  description = "Name of the service accounts in GCP/GKE and k8s"
}

variable "tekton_chains_namespace" {
  default     = "tekton-chains"
  description = "Namespace of the tekton chains controller"
}

variable "tekton_sa_name" {
  default     = "tekton-sa"
  description = "Name of the service accounts in GCP/GKE and k8s"
}

variable "tekton_working_namespace" {
  default     = "default"
  description = "Namespace where tekton workloads are running"
}

variable "REKOR_ADDRESS" {
  default     = "https://rekor.sigstore.dev"
  description = "URL for rekor"
  type        = string
}

variable "FULCIO_ADDRESS" {
  default     = "https://fulcio.sigstore.dev"
  description = "URL for fulcio"
  type        = string
}

variable "TK_PIPELINE_HELM_CHART_VERSION" {
  default     = "0.2.3"
  type        = string
  description = "Helm chart version of tekton pipeline helm chart"
}

variable "TK_PIPELINE_NAMESPACE" {
  default     = "tekton-pipelines"
  type        = string
  description = "Namespace to deploy tekton charts"
}

variable "TK_PIPELINE_HELM_REPO" {
  type        = string
  description = "tekton pipeline helm chart"
  default     = "https://chainguard-dev.github.io/tekton-helm-charts"
}

variable "TK_DASHBOARD_HELM_CHART_VERSION" {
  default     = "0.2.1"
  type        = string
  description = "Tekton Dashboard of the helm chart to deploy"
}

variable "TK_DASHBOARD_HELM_REPO" {
  type        = string
  description = "tekton dashboard helm chart repo"
  default     = "https://chainguard-dev.github.io/tekton-helm-charts"
}

variable "TK_CHAINS_NAMESPACE" {
  default     = "tekton-chains"
  type        = string
  description = "Namespace to deploy tekton chains"
}

variable "TK_CHAINS_HELM_CHART_VERSION" {
  default     = "0.2.6"
  type        = string
  description = "Helm chart version of tekton chains to deploy"
}

variable "TK_CHAINS_HELM_REPO" {
  type        = string
  description = "tekton chains helm chart repo"
  default     = "https://chainguard-dev.github.io/tekton-helm-charts"
}
