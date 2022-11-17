terraform {
  backend "s3" {
    bucket = "tekton-enforce-demo"
    key    = "dev"
    region = "us-east-1"
  }
}
