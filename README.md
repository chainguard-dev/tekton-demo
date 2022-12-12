# tekton-demo
Tekton, Enforce for Git and Kubernetes Demo  

![Demo](static/demo.png)

## Prerequisites

1. Build Kubernetes Cluster for tekton
2. Demo Kubernetes Cluster for testing Enforce for Kubernetes
3. OCI compliant Registry (GitHub Container Registry)

_Note_: You can use the same cluster for build and deploy if you'd like.

1. Deploy GKE Cluster
2. Deploy EKS Cluster
3. Deploy Tekton on GKE Cluster
4. Deploy Enforce on EKS Cluster

### GKE/EKS Cluster

Terraform will deploy both the GKE and EKS. Tekton is two steps, deploying the cluster then tekton 

1. GKE Deployment is in terraform/tekton/1-infrastructure 
2. Tekton deploy is in terraform/tekton/2-post-installation
3. EKS deployment is in terraform/eks 

The GKE cluster is deployed behind a bastion, the information to access it is in the terraform output. The GKE
commands need the bastion set for the HTTPS_PROXY. 

Now we can install the Chainguard enforce agent on the EKS Cluster, more information on how to do that is on our
[Chainguard Academy](https://edu.chainguard.dev/chainguard/chainguard-enforce/chainguard-enforce-kubernetes/how-to-connect-kubernetes-clusters/)

You are now ready for the Demos.

## Demos 

### Tools needed

1. [chainctl](https://edu.chainguard.dev/chainguard/chainguard-enforce/how-to-install-chainctl/)
2. [terraform](https://developer.hashicorp.com/terraform/downloads)
2. [gcloud cli](https://cloud.google.com/sdk/docs/install)
3. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
4. [cosign](https://docs.sigstore.dev/cosign/installation/)
5. [gitsign](https://docs.sigstore.dev/gitsign/installation/)
6. [tkn - tekton cli](https://github.com/tektoncd/cli#installing-tkn)
7. [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
8. [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

Others that our helpful not necessary 

[jq](https://stedolan.github.io/jq/download/), [yq](https://github.com/mikefarah/yq), [rekor-cli ](https://docs.sigstore.dev/rekor/cli/)

### Demo #1 Gitsign 

_Note_: This is step 1,2,3, 4 and 5 in the image 

```bash
gitsign show
```

A Git sign attestation 
```json
{
  "_type": "https://in-toto.io/Statement/v0.1",
  "predicateType": "gitsign.sigstore.dev/predicate/git/v0.1",
  "subject": [
    {
      "name": "git@github.com:chainguard-dev/tekton-demo.git",
      "digest": {
        "sha1": "da09cbd0331c2074a5ff4b337ae88bf8e6893d14"
      }
    }
  ],
  "predicate": {
    "source": {
      "tree": "dfed21bb2805cbbdc63e7ea92fff3bc20408b69a",
      "parents": [
        "a85700d6862e89084ffbdff759fefbda265afc82",
        "81a9751a2b0d0496276a18ea832c16f4d377ac92"
      ],
      "author": {
        "name": "James Strong",
        "email": "james.strong@chainguard.dev",
        "date": "2022-12-12T10:13:49-05:00"
      },
      "committer": {
        "name": "GitHub",
        "email": "noreply@github.com",
        "date": "2022-12-12T10:13:49-05:00"
      },
      "message": "Merge pull request #6 from chainguard-dev/downgrade\n\nupdates for stream and downgrade go"
    },
    "signature": "-----BEGIN PGP SIGNATURE-----\n\nwsBcBAABCAAQBQJjl0UtCRBK7hj4Ov3rIwAAEP4IABYfr1roWaE9FtZPVaDy/lmD\nmGiKWZc2JatVwXdPzxHJ17WWUZ5WCoToSMoOvkcVtLGQYe5G6BXz2SUo2OdBGulW\nFdZR3OXNhSIakVqqlu7CulzCV54pa4B1WcyXwkhHGm5y+mwSMp7nesdRGCgAOWXx\nBDfd129g3XE4mITO2rrfZXg0kJjDBGsWX5StkbUrNf0FKiDbtbVTT97Z1Bn+1rtB\nbcAIWHgqw0R3SAB1JlQnecLO37veOjh2ABu7yTw1P2hkf4m5Iw3gaM9ch9O4HgRr\ns3PBogON+hdRJm75rnNijlnC4cp50iR2FVZGvPioaAwrVOjrb+yN7fVx2xFlFMs=\n=u21/\n-----END PGP SIGNATURE-----\n\n"
  }
}
```


### Demo #2 Enforce for Git 

[How to install Chainguard Enforce for Git](https://edu.chainguard.dev/chainguard/chainguard-enforce/chainguard-enforce-github/install-enforce-github/)


Cluster Image Policy Requiring an attestation of git signed commits 

```yaml
apiVersion: policy.sigstore.dev/v1alpha1
kind: ClusterImagePolicy
metadata:
  name: keyless-attestation-gitsign-update
spec:
  images:
    - glob: ghcr.io/chainguard-dev/*
    - glob: cgr.dev/chainguard/*
    - glob: index.docker.io/library/*
  authorities:
    - name: keyless
      keyless:
        url: "https://fulcio.sigstore.dev"
        identities:
          - issuer: https://container.googleapis.com/v1/projects/customer-engineering-357819/locations/us-central1-a/clusters/tekton-dev
            subject: https://kubernetes.io/namespaces/tekton-chains/serviceaccounts/tekton-chains-controller
          - issuer: https://accounts.google.com
            subjectRegExp: .+@chainguard.dev$
      attestations:
        - name: must-have-gitsign
          predicateType: custom
          policy:
            type: cue
            data: |
              import (
                "encoding/json"
                "strings"
              )
              #Predicate: {
                Data: string
                Timestamp: string
                ...
              }
              predicate: #Predicate & {
                Data: string
                jsonData: {...} & json.Unmarshal(Data) & {
                 predicateType: "gitsign.sigstore.dev/predicate/git/v0.1"
                }
              }
```

### Demo #3 Enforce for Kubernetes 

Cluster Image Policy requiring a signed container 

```yaml
apiVersion: policy.sigstore.dev/v1alpha1
kind: ClusterImagePolicy
metadata:
  name: keyless-attestation-update
spec:
  images:
    - glob: ghcr.io/chainguard-dev/*
    - glob: cgr.dev/chainguard/*
    - glob: index.docker.io/library/*
  authorities:
    - name: keyless
      keyless:
        url: "https://fulcio.sigstore.dev"
        identities:
          - issuer: https://container.googleapis.com/v1/projects/customer-engineering-357819/locations/us-central1-a/clusters/tekton-dev
            subject: https://kubernetes.io/namespaces/tekton-chains/serviceaccounts/tekton-chains-controller
          - issuer: https://accounts.google.com
            subjectRegExp: .+@chainguard.dev$
```

