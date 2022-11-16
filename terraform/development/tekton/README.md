# Terraform Tekton

The Tekton and SPIRE implementations run in the `tekton-dev` GKE cluster in the `oci-builder-service-dev` GCP project.
The infrastructure and applications are codified in Terraform in this directory.

Terraform deployment has been split into two phases:

* [1-infrastructure](#infrastructure-phase)
* [2-post-installation](#post-installation-phase)


The infrastructure phase requires access to the GCP project to set up underlying GCP resources, including the cluster and bastion.
The post-installation phase requires access to the private cluster via the bastion, so it must be run after the infrastructure phase has been set up.
This is why the two phases have been split up.

You can think of phase 1 as setting up all required GCP resources (GKE Cluster, bastion etc), and phase 2 as setting up the applications in the cluster (Tekton, Tekton Chains, and SPIRE).

### Infrastructure Phase

This phase focuses on setting up all the underlying GCP resources.

* Private Network
* Bastion instance
  * for communicating to resources on Private Network
* GKE Cluster

This phase requires access to the GCP project.

### Post-Installation Phase

This phase focus on deploying Kubernetes applications:
* Tekton Pipelines
* Tekton Chains
* SPIRE

This phase requires access to the GKE cluster via the bastion.

### Deploying Terraform via Github Actions

Terraform is deployed via a Github Action in the `Cray-HPE/GCP-OCI-Prod-Admin-Setup` Github project.

The Github Action can be found here: https://github.com/Cray-HPE/GCP-OCI-Prod-Admin-Setup/actions/workflows/provision-tekton.yaml

There are two modes for running this workflow:
* `plan` 
* `apply`

Selecting `plan` will print out intended changes to infrastructure Terraform will make, but will not apply them.
Selecting `apply` will apply the changes to the infrastrcutre.

**Always run `plan` and ensure the changes are acceptable before running `apply`.**

## Github Actions Authentication to GCP
Github Actions is able to access the GCP project by running under the `github-actions@oci-tekton-service-dev.iam.gserviceaccount.com` service account in the `oci-tekton-service-dev` GCP project.
This service account has all required permissions to create the required Terraform infrastructure.

The authentication between GCP and Github was set up by following this [blog post](https://cloud.google.com/blog/products/identity-security/enabling-keyless-authentication-from-github-actions).
For convenience, there is a script [github-oidc-setup.sh](../scripts/github-oidc-setup.sh) that can be run to set up the Github identity pool in GCP again.

This script also creates the `github-actions@oci-tekton-service-dev.iam.gserviceaccount.com` service account if it doesn't exist and applies all required IAM roles to it.

## Connecting to the GKE Cluster

For increased security, the Tekton GKE cluster is a private cluster running in a private network.
To access this cluster, you must create an SSH tunnel via the bastion instance.

In one terminal tab, run the following to create the SSH tunnel to the bastion instance:

```
gcloud compute ssh --zone us-central1-b bastion-6767864a --tunnel-through-iap --project oci-tekton-service-dev -- -N -D 8118
```

In another terminal tab, get credentials for the cluster:

```
gcloud container clusters get-credentials --project oci-tekton-service-dev --region us-central1-a --internal-ip tekton-dev
```

With the above SSH tunnel, one can access the cluster with kubectl after setting the environment variable `HTTPS_PROXY=socks5://localhost:8118`.

For example, get all namespaces in the cluster by running:
```
HTTPS_PROXY=socks5://localhost:8118 kubectl get namespaces
```


**NOTE** The above commands for the bastion name may change. If the above commands don't work, you can get the most recent state by running the following:

```
cd terraform/development/tekton/1-infrastructure
terraform output # This should print out the most up-to-date commands
```
