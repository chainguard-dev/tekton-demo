resource "helm_release" "tekton_pipelines" {
  name             = "tekton-pipelines"
  chart            = "tekton-pipelines"
  repository       = var.TK_PIPELINE_HELM_REPO
  version          = var.TK_PIPELINE_HELM_CHART_VERSION
  namespace        = var.TK_PIPELINE_NAMESPACE
  create_namespace = true
  recreate_pods    = true
  force_update     = true
  cleanup_on_fail  = false
  timeout          = 60
  set {
    name  = "featureFlags.disable-affinity-assistant"
    value = "true"
  }
}

resource "helm_release" "tekton_dashboard" {
  depends_on       = [helm_release.tekton_pipelines]
  name             = "tekton-dashboard"
  chart            = "tekton-dashboard"
  repository       = var.TK_DASHBOARD_HELM_REPO
  version          = var.TK_DASHBOARD_HELM_CHART_VERSION
  namespace        = var.TK_PIPELINE_NAMESPACE
  create_namespace = false
  force_update     = true
  recreate_pods    = true
  cleanup_on_fail  = true
}

resource "helm_release" "tekton_chains" {
  depends_on       = [helm_release.tekton_pipelines]
  name             = "tekton-chains"
  chart            = "tekton-chains"
  repository       = var.TK_CHAINS_HELM_REPO
  version          = var.TK_CHAINS_HELM_CHART_VERSION
  namespace        = var.TK_CHAINS_NAMESPACE
  create_namespace = true
  force_update     = true
  recreate_pods    = true
  cleanup_on_fail  = true

  values = [
    <<EOF
    tenantConfig:
        artifacts.taskrun.format: in-toto
        artifacts.taskrun.storage: oci

        artifacts.oci.format: simplesigning
        artifacts.oci.storage: oci

        transparency.enabled: true
        transparency.url: ${var.REKOR_ADDRESS}

        signers.x509.fulcio.enabled: true
        signers.x509.fulcio.address: ${var.FULCIO_ADDRESS}
    EOF
  ]
}

resource "kubernetes_service_account" "tekton" {
  metadata {
    name      = var.tekton_sa_name
    namespace = "default"
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.tekton_gsa.email
    }

  }
  image_pull_secret {
    name = "registry-credentials"
  }
}


# Services account for GKE workloads, fulcio etc.
resource "google_service_account" "tekton_gsa" {
  account_id   = var.tekton_sa_name
  display_name = "GKE Service Account Workload user for Tekton"
  project      = var.project_id
}

# Allow the workload KSA to assume GSA
resource "google_service_account_iam_member" "workload_account_iam" {
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.tekton_working_namespace}/${var.tekton_sa_name}]"
  service_account_id = google_service_account.tekton_gsa.name
  depends_on         = [google_service_account.tekton_gsa]
}

# GSA Access to storage for repo
resource "google_project_iam_member" "storage_admin_member" {
  project    = var.project_id
  role       = "roles/storage.admin"
  member     = "serviceAccount:${google_service_account.tekton_gsa.email}"
  depends_on = [google_service_account.tekton_gsa]
}

resource "google_project_iam_member" "token_creation" {
  project    = var.project_id
  role       = "roles/iam.serviceAccountTokenCreator"
  member     = "serviceAccount:${google_service_account.tekton_gsa.email}"
  depends_on = [google_service_account.tekton_gsa]
}


