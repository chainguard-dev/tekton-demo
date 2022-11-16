#!/usr/bin/env bash

# Commands based off of Google blog post
# https://cloud.google.com/blog/products/identity-security/enabling-keyless-authentication-from-github-actions
#
# One addition is the attribute.repository=assertion.repository mapping.
# This allows it to be pinned to given repo.

set -o errexit
set -o nounset
set -o pipefail
set -o verbose
set -o xtrace

PROJECT_ID="${PROJECT_ID:-customer-engineering-357819}"
POOL_NAME="github-actions-pool"
PROVIDER_NAME="github-actions-provider"
LOCATION="global"

REPO="${REPO:-"chainguard-dev/tekton-demo"}"
SERVICE_ACCOUNT_ID="github-actions"
SERVICE_ACCOUNT="${SERVICE_ACCOUNT_ID}@${PROJECT_ID}.iam.gserviceaccount.com"
PROJECT_NUMBER=$(gcloud projects describe "${PROJECT_ID}" --format='value(projectNumber)')


if ! (gcloud iam workload-identity-pools describe "${POOL_NAME}" --location=${LOCATION}); then
  gcloud iam workload-identity-pools create "${POOL_NAME}" \
    --project="${PROJECT_ID}" \
    --location="${LOCATION}" \
    --display-name="Github Actions Pool"
fi

if ! (gcloud iam workload-identity-pools providers describe "${PROVIDER_NAME}" --location="${LOCATION}" --workload-identity-pool="${POOL_NAME}"); then
  gcloud iam workload-identity-pools providers create-oidc "${PROVIDER_NAME}" \
  --project="${PROJECT_ID}" \
  --location="${LOCATION}" \
  --workload-identity-pool="${POOL_NAME}" \
  --display-name="Github Actions Provider" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.aud=assertion.aud,attribute.repository=assertion.repository" \
  --issuer-uri="https://token.actions.githubusercontent.com"
fi

if ! (gcloud iam service-accounts describe "${SERVICE_ACCOUNT}"); then
gcloud iam service-accounts create ${SERVICE_ACCOUNT_ID} \
  --description="Service account for Github Actions" \
  --display-name="Github Actions"
fi

# Adding binding is idempotent.
# For Workload Identity
gcloud iam service-accounts add-iam-policy-binding "${SERVICE_ACCOUNT}" \
  --project="${PROJECT_ID}" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/${LOCATION}/workloadIdentityPools/${POOL_NAME}/attribute.repository/${REPO}"


# For service account impersonation, used for managing groups.
gcloud iam service-accounts add-iam-policy-binding "${SERVICE_ACCOUNT}" \
  --project="${PROJECT_ID}" \
  --role="roles/iam.serviceAccountTokenCreator" \
  --member="serviceAccount:${SERVICE_ACCOUNT}"


# Adding binding is idempotent.
# For creating Cloud SQL instance for Trillian
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --project="${PROJECT_ID}" \
  --role="roles/cloudsql.admin" \
  --member="serviceAccount:${SERVICE_ACCOUNT}"

# Adding binding is idempotent.
# For creating standalone Node Pool for GKE running as service accounts.
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --project="${PROJECT_ID}" \
  --role="roles/iam.serviceAccountUser" \
  --member="serviceAccount:${SERVICE_ACCOUNT}"

# Adding binding is idempotent.
# For creating standalone Node Pool for GKE, and IAP tunnel for Bastion to GKE access.
# This may be extreme, but I couldn't find a good narrowly scoped role with
# compute.instanceGroupManagers.*
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --project="${PROJECT_ID}" \
  --role="roles/compute.instanceAdmin" \
  --member="serviceAccount:${SERVICE_ACCOUNT}"

# Adding binding is idempotent.
# For ssh tunnel from Bastion to GKE access.
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --project="${PROJECT_ID}" \
  --role="roles/iap.tunnelResourceAccessor" \
  --member="serviceAccount:${SERVICE_ACCOUNT}"

# Adding binding is idempotent.
# For creating GKE cluster.
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --project="${PROJECT_ID}" \
  --role="roles/container.admin" \
  --member="serviceAccount:${SERVICE_ACCOUNT}"

# Adding binding is idempotent.
# For creating Service Accounts that maps to Kubernetes Service Accounts.
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --project="${PROJECT_ID}" \
  --role="roles/iam.serviceAccountAdmin" \
  --member="serviceAccount:${SERVICE_ACCOUNT}"

# Adding binding is idempotent.
# For managing Service Account role membership.
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --project="${PROJECT_ID}" \
  --role="roles/resourcemanager.projectIamAdmin" \
  --member="serviceAccount:${SERVICE_ACCOUNT}"

# Adding binding is idempotent.
# For enabling service API.
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --project="${PROJECT_ID}" \
  --role="roles/serviceusage.serviceUsageAdmin" \
  --member="serviceAccount:${SERVICE_ACCOUNT}"

# Adding binding is idempotent.
# For writing Terraform state to GCS.
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --project="${PROJECT_ID}" \
  --role="roles/storage.admin" \
  --member="serviceAccount:${SERVICE_ACCOUNT}"

# Adding binding is idempotent.
# For creating KMS ring and keys.
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --project="${PROJECT_ID}" \
  --role="roles/cloudkms.admin" \
  --member="serviceAccount:${SERVICE_ACCOUNT}"

# Adding binding is idempotent.
# For creating private network for GKE/Cloud SQL.
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --project="${PROJECT_ID}" \
  --role="roles/servicenetworking.networksAdmin" \
  --member="serviceAccount:${SERVICE_ACCOUNT}"

# Adding binding is idempotent.
# For Monitoring Alerting Policies.
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --project="${PROJECT_ID}" \
  --role="roles/monitoring.alertPolicyEditor" \
  --member="serviceAccount:${SERVICE_ACCOUNT}"

# Adding binding is idempotent.
# For creating networks; compute.networks.create
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --project="${PROJECT_ID}" \
  --role="roles/compute.networkAdmin" \
  --member="serviceAccount:${SERVICE_ACCOUNT}"

# Adding binding is idempotent.
# For creating networks; compute.firewalls.create
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --project="${PROJECT_ID}" \
  --role="roles/compute.securityAdmin" \
  --member="serviceAccount:${SERVICE_ACCOUNT}"


# Adding binding is idempotent.
# For creating Workload identity pool.
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --project="${PROJECT_ID}" \
  --role="roles/iam.workloadIdentityPoolAdmin" \
  --member="serviceAccount:${SERVICE_ACCOUNT}"

# Adding binding is idempotent.
# For creating Workload identity pool.
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --project="${PROJECT_ID}" \
  --role="roles/iam.serviceAccountKeyAdmin" \
  --member="serviceAccount:${SERVICE_ACCOUNT}"

# Adding binding is idempotent.
# For creating secrets in secretmanager.
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --project="${PROJECT_ID}" \
  --role="roles/secretmanager.admin" \
  --member="serviceAccount:${SERVICE_ACCOUNT}"

# Adding binding is idempotent.
# For creating Certificate Authority.
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --project="${PROJECT_ID}" \
  --role="roles/privateca.caManager" \
  --member="serviceAccount:${SERVICE_ACCOUNT}"
  
# Adding binding is idempotent.
# For creating redis for Rekor.
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --project="${PROJECT_ID}" \
  --role="roles/redis.admin" \
  --member="serviceAccount:${SERVICE_ACCOUNT}"

