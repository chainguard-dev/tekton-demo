
terraform {
  backend "gcs" {
    # Remote backend for tf state
    bucket = "tekton-demo"
    prefix = "/terraform/dev/ci/"
  }
}
