# Services account for GKE workloads, fulcio etc.
resource "google_service_account" "tekton_chains_gsa" {
  account_id   = var.tekton_chains_sa_name
  display_name = "GKE Service Account Workload user for Tekton Chains"
  project      = var.project_id
}

resource "kubernetes_annotations" "tekton_chains" {
  api_version = "v1"
  kind        = "ServiceAccount"
  metadata {
    name      = var.tekton_chains_sa_name
    namespace = var.tekton_chains_namespace
  }

  annotations = {
    "iam.gke.io/gcp-service-account" = google_service_account.tekton_chains_gsa.email
  }
}

resource "null_resource" "image_pull" {

  provisioner "local-exec" {
    command = "kubectl patch serviceaccount ${var.tekton_chains_sa_name} -p '{\"imagePullSecrets\": [{\"name\": \"registry-credentials\"}]}' -n ${var.tekton_chains_namespace}"
  }
}

resource "null_resource" "restart_chains" {
  provisioner "local-exec" {
    command = "kubectl rollout restart deployment/tekton-chains-controller -n ${var.tekton_chains_namespace}"
  }
}

# Allow the workload KSA to assume GSA
resource "google_service_account_iam_member" "tekton_chains_workload_account_iam" {
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.tekton_chains_namespace}/${var.tekton_sa_name}]"
  service_account_id = google_service_account.tekton_chains_gsa.name
  depends_on         = [google_service_account.tekton_chains_gsa]
}

# GSA Access to storage for repo
resource "google_project_iam_member" "tekton_chains_storage_admin_member" {
  project    = var.project_id
  role       = "roles/storage.admin"
  member     = "serviceAccount:${google_service_account.tekton_chains_gsa.email}"
  depends_on = [google_service_account.tekton_chains_gsa]
}

resource "google_project_iam_member" "tekton_chains_token_creation" {
  project    = var.project_id
  role       = "roles/iam.serviceAccountTokenCreator"
  member     = "serviceAccount:${google_service_account.tekton_chains_gsa.email}"
  depends_on = [google_service_account.tekton_chains_gsa]
}