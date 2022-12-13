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
3. [gcloud cli](https://cloud.google.com/sdk/docs/install)
4. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
5. [cosign](https://docs.sigstore.dev/cosign/installation/)
6. [gitsign](https://docs.sigstore.dev/gitsign/installation/)
7. [tkn - tekton cli](https://github.com/tektoncd/cli#installing-tkn)
8. [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
9. [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

Others that our helpful not necessary 

[jq](https://stedolan.github.io/jq/download/), [yq](https://github.com/mikefarah/yq), [rekor-cli ](https://docs.sigstore.dev/rekor/cli/)

### Demo #1 Gitsign 

_Note_: This is step 1,2,3, 4 and 5 in the image 

```bash
git checkout -b readme
Switched to a new branch 'readme'
[strongjz@hulk-linux tekton-demo]$ git status
On branch readme
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        modified:   README.md
        modified:   config/gcp/pipeline.yaml
        modified:   config/go/ko-build-image.yaml
        deleted:    kind.yaml
        deleted:    setup.sh
        new file:   static/demo.png

[strongjz@hulk-linux tekton-demo]$ git commit -sm"update readme"
error getting cached creds: "/home/strongjz/Documents/code/go/src/github.com/chainguard-dev/tekton-demo" not found
Your browser will now be opened to:
https://oauth2.sigstore.dev/auth/auth?access_type=online&client_id=sigstore&code_challenge=p_j8JRojZS01K7zqbk9X19OBhKLRMqAO8t-XOCty2MA&code_challenge_method=S256&nonce=2IpQx7Xp7tfe3J1DNMMF9KJBRl1&redirect_uri=http%3A%2F%2Flocalhost%3A38113%2Fauth%2Fcallback&response_type=code&scope=openid+email&state=2IpQxC57BSU3I757W5ciGcu3Jy0
tlog entry created with index: 8954011
[readme 814cf8d] update readme
 6 files changed, 172 insertions(+), 389 deletions(-)
 delete mode 100644 kind.yaml
 delete mode 100755 setup.sh
 create mode 100644 static/demo.png
[strongjz@hulk-linux tekton-demo]$ 
[strongjz@hulk-linux tekton-demo]$ git push origin readme
Enumerating objects: 17, done.
Counting objects: 100% (17/17), done.
Delta compression using up to 32 threads
Compressing objects: 100% (9/9), done.
Writing objects: 100% (10/10), 126.96 KiB | 11.54 MiB/s, done.
Total 10 (delta 4), reused 0 (delta 0), pack-reused 0
remote: Resolving deltas: 100% (4/4), completed with 4 local objects.
remote: 
remote: Create a pull request for 'readme' on GitHub by visiting:
remote:      https://github.com/chainguard-dev/tekton-demo/pull/new/readme
remote: 
To github.com:chainguard-dev/tekton-demo.git
 * [new branch]      readme -> readme
```


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
        "sha1": "814cf8d02a07a46694fc39d8811dde061d485b13"
      }
    }
  ],
  "predicate": {
    "source": {
      "tree": "209e2755dd4ca173619c82edd5cf098ae6b047b7",
      "parents": [
        "da09cbd0331c2074a5ff4b337ae88bf8e6893d14"
      ],
      "author": {
        "name": "James Strong",
        "email": "james.strong@chainguard.dev",
        "date": "2022-12-12T15:18:08-05:00"
      },
      "committer": {
        "name": "James Strong",
        "email": "james.strong@chainguard.dev",
        "date": "2022-12-12T15:18:08-05:00"
      },
      "message": "update readme\n\nSigned-off-by: James Strong \u003cjames.strong@chainguard.dev\u003e\n"
    },
    "signature": "-----BEGIN SIGNED MESSAGE-----\nMIIECwYJKoZIhvcNAQcCoIID/DCCA/gCAQExDTALBglghkgBZQMEAgEwCwYJKoZI\nhvcNAQcBoIICrDCCAqgwggItoAMCAQICFFRhliM8NDTvwn9qMNW8Ps7NzvqjMAoG\nCCqGSM49BAMDMDcxFTATBgNVBAoTDHNpZ3N0b3JlLmRldjEeMBwGA1UEAxMVc2ln\nc3RvcmUtaW50ZXJtZWRpYXRlMB4XDTIyMTIxMjIwMTgxNFoXDTIyMTIxMjIwMjgx\nNFowADBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABCQh79rnJjzz26gFTJpQs1Ko\ntaFhIEzyCmyaxxw6F7zpT8/TqYjNEzyoapOsRNrPWR+1J9yMnqFga5SIMSrUiRyj\nggFMMIIBSDAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMwHQYD\nVR0OBBYEFLruBp6TaDSq0ZZ7wvmJ0kY5t8B5MB8GA1UdIwQYMBaAFN/T6c9WJBGW\n+ajY6ShVosYuGGQ/MCkGA1UdEQEB/wQfMB2BG2phbWVzLnN0cm9uZ0BjaGFpbmd1\nYXJkLmRldjApBgorBgEEAYO/MAEBBBtodHRwczovL2FjY291bnRzLmdvb2dsZS5j\nb20wgYoGCisGAQQB1nkCBAIEfAR6AHgAdgDdPTBqxscRMmMZHhyZZzcCokpeuN48\nrf+HinKALynujgAAAYUH/O5wAAAEAwBHMEUCIDoql4eB1XMp/vTUWKv28Q0aM+Oe\nXkLp36cHKtV15p5wAiEA3pWCHk/FfMLnaHmeU6lACVQCrShUyF0I2vg3Lo2Sf3Yw\nCgYIKoZIzj0EAwMDaQAwZgIxAOVU+Z9aFP1I8QB5zeBVd2MbTPShThTePUzH84Rl\nA2w6zNEMvvvM4XI+b+UlBJWL8wIxAO57Xbp+vb8Pmvhu2ZRQH5z8Txw8RQvF8Vxi\n/R4KkfWIdg3KbnbYqp8+NqgWvxZo4TGCASUwggEhAgEBME8wNzEVMBMGA1UEChMM\nc2lnc3RvcmUuZGV2MR4wHAYDVQQDExVzaWdzdG9yZS1pbnRlcm1lZGlhdGUCFFRh\nliM8NDTvwn9qMNW8Ps7NzvqjMAsGCWCGSAFlAwQCAaBpMBgGCSqGSIb3DQEJAzEL\nBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTIyMTIxMjIwMTgxN1owLwYJKoZI\nhvcNAQkEMSIEIOtoDT1tODgjWiAHP91ANr98NDMkEO59RZbD8yRKx+M3MAoGCCqG\nSM49BAMCBEcwRQIhAMEHnNxiW54gbVEW7SnL52H7dCCBtDTMISx/uM5VOxe6AiBg\nOVljutveX/cLT+/EQzVUs9dpb83hlUx9J7funrKLpg==\n-----END SIGNED MESSAGE-----\n",
    "signer_info": [
      {
        "attributes": "MWkwGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMjIxMjEyMjAxODE3WjAvBgkqhkiG9w0BCQQxIgQg62gNPW04OCNaIAc/3UA2v3w0MyQQ7n1FlsPzJErH4zc=",
        "certificate": "-----BEGIN CERTIFICATE-----\nMIICqDCCAi2gAwIBAgIUVGGWIzw0NO/Cf2ow1bw+zs3O+qMwCgYIKoZIzj0EAwMw\nNzEVMBMGA1UEChMMc2lnc3RvcmUuZGV2MR4wHAYDVQQDExVzaWdzdG9yZS1pbnRl\ncm1lZGlhdGUwHhcNMjIxMjEyMjAxODE0WhcNMjIxMjEyMjAyODE0WjAAMFkwEwYH\nKoZIzj0CAQYIKoZIzj0DAQcDQgAEJCHv2ucmPPPbqAVMmlCzUqi1oWEgTPIKbJrH\nHDoXvOlPz9OpiM0TPKhqk6xE2s9ZH7Un3IyeoWBrlIgxKtSJHKOCAUwwggFIMA4G\nA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEFBQcDAzAdBgNVHQ4EFgQUuu4G\nnpNoNKrRlnvC+YnSRjm3wHkwHwYDVR0jBBgwFoAU39Ppz1YkEZb5qNjpKFWixi4Y\nZD8wKQYDVR0RAQH/BB8wHYEbamFtZXMuc3Ryb25nQGNoYWluZ3VhcmQuZGV2MCkG\nCisGAQQBg78wAQEEG2h0dHBzOi8vYWNjb3VudHMuZ29vZ2xlLmNvbTCBigYKKwYB\nBAHWeQIEAgR8BHoAeAB2AN09MGrGxxEyYxkeHJlnNwKiSl643jyt/4eKcoAvKe6O\nAAABhQf87nAAAAQDAEcwRQIgOiqXh4HVcyn+9NRYq/bxDRoz455eQunfpwcq1XXm\nnnACIQDelYIeT8V8wudoeZ5TqUAJVAKtKFTIXQja+DcujZJ/djAKBggqhkjOPQQD\nAwNpADBmAjEA5VT5n1oU/UjxAHnN4FV3YxtM9KFOFN49TMfzhGUDbDrM0Qy++8zh\ncj5v5SUElYvzAjEA7ntdun69vw+a+G7ZlFAfnPxPHDxFC8XxXGL9HgqR9Yh2Dcpu\ndtiqnz42qBa/Fmjh\n-----END CERTIFICATE-----\n"
      }
    ]
  }
}
```



### Demo #2 Enforce for Git 

[How to install Chainguard Enforce for Git](https://edu.chainguard.dev/chainguard/chainguard-enforce/chainguard-enforce-github/install-enforce-github/)

You can see in the PR https://github.com/chainguard-dev/tekton-demo/pull/7 that my commits were verified by Enforce for Git 


![](static/enforce-check.png)


https://github.com/chainguard-dev/tekton-demo/pull/7/checks?check_run_id=10046716604

![](static/pr-check.png)


```bash
export IMAGE_ID=ghcr.io/chainguard-dev/tekton-demo:da09cbd@sha256:aaa82ba50684376426cdf84ebfeea34ea4e8fdb1191574b800559ab027f9e24d
[strongjz@hulk-linux tekton-demo]$ cosign attest --file <(gitsign show) $IMAGE_ID
Error: unknown flag: --file
main.go:62: error during command execution: unknown flag: --file
[strongjz@hulk-linux tekton-demo]$ cosign attest --predicate <(gitsign show) $IMAGE_ID
Generating ephemeral keys...
Retrieving signed certificate...

        Note that there may be personally identifiable information associated with this signed artifact.
        This may include the email address associated with the account with which you authenticate.
        This information will be used for signing this artifact and will be stored in public transparency logs and cannot be removed later.
        By typing 'y', you attest that you grant (or have permission to grant) and agree to have this information stored permanently in transparency logs.

Are you sure you want to continue? (y/[N]): y
Your browser will now be opened to:
https://oauth2.sigstore.dev/auth/auth?access_type=online&client_id=sigstore&code_challenge=CtXEmIqW92Wvyq5dCc1gqmRKJpw3WsGf__h0balZVrk&code_challenge_method=S256&nonce=2IpS54S8MOKXKbH3GYvH5BgqDka&redirect_uri=http%3A%2F%2Flocalhost%3A40421%2Fauth%2Fcallback&response_type=code&scope=openid+email&state=2IpS53Pznww1pusCFoIsxcmfmek
Successfully verified SCT...
Using payload from: /dev/fd/63
using ephemeral certificate:
-----BEGIN CERTIFICATE-----
MIICpzCCAiygAwIBAgIUEq0/s3JFzfALAY00Qx5UjD4XXBswCgYIKoZIzj0EAwMw
NzEVMBMGA1UEChMMc2lnc3RvcmUuZGV2MR4wHAYDVQQDExVzaWdzdG9yZS1pbnRl
cm1lZGlhdGUwHhcNMjIxMjEyMjAyNzI5WhcNMjIxMjEyMjAzNzI5WjAAMFkwEwYH
KoZIzj0CAQYIKoZIzj0DAQcDQgAEjmMpLaLJ25PETcJqORoVNdeOdN4HHTAMzJmn
fqF2Xt/FpF16abk5J1a+6Gx8WbWYa8GTf6MfyJURl0crFcJ4gKOCAUswggFHMA4G
A1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEFBQcDAzAdBgNVHQ4EFgQUPEMC
RviIyZhBPg0knc9U9PaewlYwHwYDVR0jBBgwFoAU39Ppz1YkEZb5qNjpKFWixi4Y
ZD8wKQYDVR0RAQH/BB8wHYEbamFtZXMuc3Ryb25nQGNoYWluZ3VhcmQuZGV2MCkG
CisGAQQBg78wAQEEG2h0dHBzOi8vYWNjb3VudHMuZ29vZ2xlLmNvbTCBiQYKKwYB
BAHWeQIEAgR7BHkAdwB1AN09MGrGxxEyYxkeHJlnNwKiSl643jyt/4eKcoAvKe6O
AAABhQgFZiQAAAQDAEYwRAIgUY6E9nLyG/Fa1/wGacNBuDpMMGmx+Efcra/Hm60C
ObYCID2lGhTtS8OBJqstzer7uw0oWjujrV4p/YG90KswIsqqMAoGCCqGSM49BAMD
A2kAMGYCMQCvWce1jQfsVY4nomqgg23L8+5LyN4iRax6J3xZAqfoN3cdFy/QiLyc
s5BZ8N62OOACMQC6YtdU8A6jDjqF6o9tesyONHRxrmn9XqfGF8aj647FxuLBS7w+
H9fmTKrind2qG6s=
-----END CERTIFICATE-----

tlog entry created with index: 8954485
```

Then you can Verify it 

```bash
cosign verify-attestation $IMAGE_ID | jq -r .payload | base64 -d | jq

Verification for ghcr.io/chainguard-dev/tekton-demo:da09cbd@sha256:aaa82ba50684376426cdf84ebfeea34ea4e8fdb1191574b800559ab027f9e24d --
The following checks were performed on each of these signatures:
  - The cosign claims were validated
  - Existence of the claims in the transparency log was verified offline
  - Any certificates were verified against the Fulcio roots.
Certificate subject:  james.strong@chainguard.dev
Certificate issuer URL:  https://accounts.google.com
{
  "_type": "https://in-toto.io/Statement/v0.1",
  "predicateType": "cosign.sigstore.dev/attestation/v1",
  "subject": [
    {
      "name": "ghcr.io/chainguard-dev/tekton-demo",
      "digest": {
        "sha256": "aaa82ba50684376426cdf84ebfeea34ea4e8fdb1191574b800559ab027f9e24d"
      }
    }
  ],
  "predicate": {
    "Data": "{\n  \"_type\": \"https://in-toto.io/Statement/v0.1\",\n  \"predicateType\": \"gitsign.sigstore.dev/predicate/git/v0.1\",\n  \"subject\": [\n    {\n      \"name\": \"git@github.com:chainguard-dev/tekton-demo.git\",\n      \"digest\": {\n        \"sha1\": \"814cf8d02a07a46694fc39d8811dde061d485b13\"\n      }\n    }\n  ],\n  \"predicate\": {\n    \"source\": {\n      \"tree\": \"209e2755dd4ca173619c82edd5cf098ae6b047b7\",\n      \"parents\": [\n        \"da09cbd0331c2074a5ff4b337ae88bf8e6893d14\"\n      ],\n      \"author\": {\n        \"name\": \"James Strong\",\n        \"email\": \"james.strong@chainguard.dev\",\n        \"date\": \"2022-12-12T15:18:08-05:00\"\n      },\n      \"committer\": {\n        \"name\": \"James Strong\",\n        \"email\": \"james.strong@chainguard.dev\",\n        \"date\": \"2022-12-12T15:18:08-05:00\"\n      },\n      \"message\": \"update readme\\n\\nSigned-off-by: James Strong \\u003cjames.strong@chainguard.dev\\u003e\\n\"\n    },\n    \"signature\": \"-----BEGIN SIGNED MESSAGE-----\\nMIIECwYJKoZIhvcNAQcCoIID/DCCA/gCAQExDTALBglghkgBZQMEAgEwCwYJKoZI\\nhvcNAQcBoIICrDCCAqgwggItoAMCAQICFFRhliM8NDTvwn9qMNW8Ps7NzvqjMAoG\\nCCqGSM49BAMDMDcxFTATBgNVBAoTDHNpZ3N0b3JlLmRldjEeMBwGA1UEAxMVc2ln\\nc3RvcmUtaW50ZXJtZWRpYXRlMB4XDTIyMTIxMjIwMTgxNFoXDTIyMTIxMjIwMjgx\\nNFowADBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABCQh79rnJjzz26gFTJpQs1Ko\\ntaFhIEzyCmyaxxw6F7zpT8/TqYjNEzyoapOsRNrPWR+1J9yMnqFga5SIMSrUiRyj\\nggFMMIIBSDAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMwHQYD\\nVR0OBBYEFLruBp6TaDSq0ZZ7wvmJ0kY5t8B5MB8GA1UdIwQYMBaAFN/T6c9WJBGW\\n+ajY6ShVosYuGGQ/MCkGA1UdEQEB/wQfMB2BG2phbWVzLnN0cm9uZ0BjaGFpbmd1\\nYXJkLmRldjApBgorBgEEAYO/MAEBBBtodHRwczovL2FjY291bnRzLmdvb2dsZS5j\\nb20wgYoGCisGAQQB1nkCBAIEfAR6AHgAdgDdPTBqxscRMmMZHhyZZzcCokpeuN48\\nrf+HinKALynujgAAAYUH/O5wAAAEAwBHMEUCIDoql4eB1XMp/vTUWKv28Q0aM+Oe\\nXkLp36cHKtV15p5wAiEA3pWCHk/FfMLnaHmeU6lACVQCrShUyF0I2vg3Lo2Sf3Yw\\nCgYIKoZIzj0EAwMDaQAwZgIxAOVU+Z9aFP1I8QB5zeBVd2MbTPShThTePUzH84Rl\\nA2w6zNEMvvvM4XI+b+UlBJWL8wIxAO57Xbp+vb8Pmvhu2ZRQH5z8Txw8RQvF8Vxi\\n/R4KkfWIdg3KbnbYqp8+NqgWvxZo4TGCASUwggEhAgEBME8wNzEVMBMGA1UEChMM\\nc2lnc3RvcmUuZGV2MR4wHAYDVQQDExVzaWdzdG9yZS1pbnRlcm1lZGlhdGUCFFRh\\nliM8NDTvwn9qMNW8Ps7NzvqjMAsGCWCGSAFlAwQCAaBpMBgGCSqGSIb3DQEJAzEL\\nBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTIyMTIxMjIwMTgxN1owLwYJKoZI\\nhvcNAQkEMSIEIOtoDT1tODgjWiAHP91ANr98NDMkEO59RZbD8yRKx+M3MAoGCCqG\\nSM49BAMCBEcwRQIhAMEHnNxiW54gbVEW7SnL52H7dCCBtDTMISx/uM5VOxe6AiBg\\nOVljutveX/cLT+/EQzVUs9dpb83hlUx9J7funrKLpg==\\n-----END SIGNED MESSAGE-----\\n\",\n    \"signer_info\": [\n      {\n        \"attributes\": \"MWkwGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMjIxMjEyMjAxODE3WjAvBgkqhkiG9w0BCQQxIgQg62gNPW04OCNaIAc/3UA2v3w0MyQQ7n1FlsPzJErH4zc=\",\n        \"certificate\": \"-----BEGIN CERTIFICATE-----\\nMIICqDCCAi2gAwIBAgIUVGGWIzw0NO/Cf2ow1bw+zs3O+qMwCgYIKoZIzj0EAwMw\\nNzEVMBMGA1UEChMMc2lnc3RvcmUuZGV2MR4wHAYDVQQDExVzaWdzdG9yZS1pbnRl\\ncm1lZGlhdGUwHhcNMjIxMjEyMjAxODE0WhcNMjIxMjEyMjAyODE0WjAAMFkwEwYH\\nKoZIzj0CAQYIKoZIzj0DAQcDQgAEJCHv2ucmPPPbqAVMmlCzUqi1oWEgTPIKbJrH\\nHDoXvOlPz9OpiM0TPKhqk6xE2s9ZH7Un3IyeoWBrlIgxKtSJHKOCAUwwggFIMA4G\\nA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEFBQcDAzAdBgNVHQ4EFgQUuu4G\\nnpNoNKrRlnvC+YnSRjm3wHkwHwYDVR0jBBgwFoAU39Ppz1YkEZb5qNjpKFWixi4Y\\nZD8wKQYDVR0RAQH/BB8wHYEbamFtZXMuc3Ryb25nQGNoYWluZ3VhcmQuZGV2MCkG\\nCisGAQQBg78wAQEEG2h0dHBzOi8vYWNjb3VudHMuZ29vZ2xlLmNvbTCBigYKKwYB\\nBAHWeQIEAgR8BHoAeAB2AN09MGrGxxEyYxkeHJlnNwKiSl643jyt/4eKcoAvKe6O\\nAAABhQf87nAAAAQDAEcwRQIgOiqXh4HVcyn+9NRYq/bxDRoz455eQunfpwcq1XXm\\nnnACIQDelYIeT8V8wudoeZ5TqUAJVAKtKFTIXQja+DcujZJ/djAKBggqhkjOPQQD\\nAwNpADBmAjEA5VT5n1oU/UjxAHnN4FV3YxtM9KFOFN49TMfzhGUDbDrM0Qy++8zh\\ncj5v5SUElYvzAjEA7ntdun69vw+a+G7ZlFAfnPxPHDxFC8XxXGL9HgqR9Yh2Dcpu\\ndtiqnz42qBa/Fmjh\\n-----END CERTIFICATE-----\\n\"\n      }\n    ]\n  }\n}\n",
    "Timestamp": "2022-12-12T20:27:29Z"
  }
}
```

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


Install of Chainguard Enforce for Kubernetes is available in our 
[Chainguard Academy documentation](https://edu.chainguard.dev/chainguard/chainguard-enforce/chainguard-enforce-kubernetes/how-to-connect-kubernetes-clusters/)

The console is available at console.enforce.dev , we also have a CLI tool for interacting with Chainguard Enforce for Kubernetes, [chainctl](https://edu.chainguard.dev/chainguard/chainguard-enforce/chainctl-docs/)

Policies and Clusters are tied to groups, below is the group for the demo named tekton-demo. 

```bash
chainctl iam group describe tekton-demo
Id: d3a4a2b6f25b36c57eed2b7732fd1bfe7ff6d2b7/5b5a2c59dd2663ef
Name: tekton-demo
Hierarchy:
[customers-aws-root-group]
└ [tekton-demo]
```

Here is the Cluster Image Policy requiring a signed container with the Identity of
either our Tekton Build pipeline or a Chainguard Google account

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


1. Update Kubeconfig with AWS EKS credentials `aws eks update-kubeconfig --name tekton-demo-pov`
2. Install Enforce with Chainctl `chainctl cluster install --group tekton-demo --name tekton-demo-pov --description "Tekton Demo for Live Stream"`
3. Create Policy `chainctl policy apply -f policy/signing.yaml`
4. Deploy Images that match policy


Cluster Install 
```bash
chainctl cluster install --group tekton-demo --name tekton-demo-pov --description "Tekton Demo for Live Stream"

Installing cluster in group tekton-demo (d3a4a2b6f25b36c57eed2b7732fd1bfe7ff6d2b7/5b5a2c59dd2663ef).
                                                                                
    Selected Cluster arn:aws:eks:us-east-1:1234567890:cluster/tekton-demo-pov.
                                                                                
Installing Chainguard agent...
Generating temporary invite code...
Configuring agent credentials...
Waiting for Chainguard agent to be ready...
Checking the webhook is available.
Programming the Chainguard agent...
Cluster has been successfully configured with ID: b69c4c24-cd29-4573-86a0-3205fb82d8e2
Cleaning up temporary invite code d3a4a2b6f25b36c57eed2b7732fd1bfe7ff6d2b7/5b5a2c59dd2663ef/ebdded177d9e70de...
```

```bash 
chainctl cluster list --group tekton-demo
NAME       |    GROUP    |               REMOTEID               | REGISTERED |     K8S VERSION      | AGENT VERSION | LAST SEEN |   ACTIVITY    
------------------+-------------+--------------------------------------+------------+----------------------+---------------+-----------+---------------
tekton-demo-pov | tekton-demo | b69c4c24-cd29-4573-86a0-3205fb82d8e2 |       5m6s | v1.23.13-eks-fb459a0 |       badf10d |       32s | enforcer:32s  
|             |                                      |            |                      |               |           | observer:35s
```

Policy Install 

```bash
chainctl policy apply -f policy/signing.yaml --group tekton-demo
                                      ID                                     |            NAME            | DESCRIPTION  
-----------------------------------------------------------------------------+----------------------------+--------------
  d3a4a2b6f25b36c57eed2b7732fd1bfe7ff6d2b7/5b5a2c59dd2663ef/7027e542b3e177c7 | keyless-attestation-update |   
```

```bash
chainctl policy view d3a4a2b6f25b36c57eed2b7732fd1bfe7ff6d2b7/5b5a2c59dd2663ef/7027e542b3e177c7
# Policy keyless-attestation-update [d3a4a2b6f25b36c57eed2b7732fd1bfe7ff6d2b7/5b5a2c59dd2663ef/7027e542b3e177c7]
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
          - issuer: https://token.actions.githubusercontent.com
            subject: https://github.com/chainguard-images/images/.github/workflows/release.yaml@refs/heads/main
          - issuer: https://container.googleapis.com/v1/projects/customer-engineering-357819/locations/us-central1-a/clusters/tekton-demo
            subject: https://kubernetes.io/namespaces/tekton-chains/serviceaccounts/tekton-chains-controller
          - issuer: https://accounts.google.com
            subjectRegExp: .+@chainguard.dev$
```

Deploy an image that matches Policy 

```bash
kubectl create deployment --image ghcr.io/chainguard-dev/tekton-demo:da09cbd
deployment.apps/tekton-demo created
```

We can see that the Container image matches the policy is passing the policy requirements 

```bash
chainctl cluster records list tekton-demo-pov
                                       IMAGE                                      |              POLICIES              |  WORKLOADS  |  ANCESTRY  | PACKAGES | LAST SEEN | LAST REFRESHED  
----------------------------------------------------------------------------------+------------------------------------+-------------+------------+----------+-----------+-----------------                 
  ghcr.io/chainguard-dev/tekton-demo@sha256:aaa82b…                               | keyless-attestation-update:pass:4s | Pod:1       | parents:1  | golang:1 | 9m33s     | sbom:4s         
                                                                                  |                                    |             |            | oci:1    |           | sig:4s          
  123456789012.dkr.ecr.us-east-1.amazonaws.com/amazon-k8s-cni-init@sha256:27aebe… |                                    | Pod:3       |            |          | 13m       |                 
  123456789012.dkr.ecr.us-east-1.amazonaws.com/amazon-k8s-cni@sha256:19dacc…      |                                    | Pod:3       |            |          | 13m       |                 
  123456789012.dkr.ecr.us-east-1.amazonaws.com/eks/coredns@sha256:e6a38c…         |                                    | Pod:2       |            |          | 13m       |                 
  123456789012.dkr.ecr.us-east-1.amazonaws.com/eks/kube-proxy@sha256:699b73…      |                                    | Pod:3       |            |          | 13m       |                 
  quay.io/cilium/cilium:v1.12.1@sha256:ea2db1…                                    |                                    | DaemonSet:1 |            |          | 13m       |                 
  quay.io/cilium/cilium@sha256:ea2db1…                                            |                                    | Pod:3       |            |          | 13m       |                 
  quay.io/cilium/hubble-relay:v1.12.1@sha256:646582…                              |                                    | Unknown:2   |            |          | 13m       |                 
  quay.io/cilium/hubble-relay@sha256:646582…                                      |                                    | Pod:1       |            |          | 13m       |                 
  quay.io/cilium/hubble-ui-backend:v0.9.1@sha256:c4b86e…                          |                                    | Unknown:2   |            |          | 13m       |                 
  quay.io/cilium/hubble-ui-backend@sha256:c4b86e…                                 |                                    | Unknown:1   |            |          | 13m       |                 
  quay.io/cilium/hubble-ui:v0.9.1@sha256:baff61…                                  |                                    | Unknown:2   |            |          | 13m       |                 
  quay.io/cilium/hubble-ui@sha256:baff61…                                         |                                    | Unknown:1   |            |          | 13m       |                 
  quay.io/cilium/operator-aws:v1.12.1@sha256:cbd071…                              |                                    | Unknown:2   |            |          | 13m       |                 
  quay.io/cilium/operator-aws@sha256:cbd071…                                      |                                    | Pod:2       |            |          | 13m       |                 
  quay.io/cilium/startup-script@sha256:0862c6…                                    |                                    | Pod:1       |            |          | 13m       |                 
                                                                                  |                                    | Unknown:2   |            |          |           |                 
  registry.k8s.io/ingress-nginx/controller-chroot:v1.5.1@sha256:c1c091…           |                                    | Unknown:2   |            |          | 13m       |                 
  registry.k8s.io/ingress-nginx/controller-chroot@sha256:c1c091…                  |                                    | Pod:1       |            |          | 13m       |                 
  us.gcr.io/prod-enforce-fabc/chainctl@sha256:86131b…                             |                                    | Pod:1       |            |          | 13m       |                 
                                                                                  |                                    | Unknown:2   |            |          |           |                 
  us.gcr.io/prod-enforce-fabc/controlplane@sha256:825856…                         |                                    | Pod:1       |            |          | 13m       |                 
                                                                                  |                                    | Unknown:2   |            |          |           |                 
```

Now Lets require a Sign SBOM attestation. 

1. Deploy the policy
2. Explore the failing policy
3. Remediate the policy

```bash
chainctl policy apply -f policy/sbom.yaml --group tekton-demo
```

We can see the failing policy now in the chainctl cluster record output 

```bash
chainctl cluster records list tekton-demo-pov
                                       IMAGE                                      |                  POLICIES                  |  WORKLOADS  |  ANCESTRY  | PACKAGES | LAST SEEN | LAST REFRESHED  
----------------------------------------------------------------------------------+--------------------------------------------+-------------+------------+----------+-----------+-----------------
  ghcr.io/chainguard-dev/tekton-demo@sha256:aaa82b…                               | keyless-attestation-sbom-spdxjson:fail:11s | Pod:1       | parents:1  | golang:1 | 13m       | sbom:11s        
                                                                                  | keyless-attestation-update:pass:4m24s      |             |            | oci:1    |           | sig:4m24s       
  123456789012.dkr.ecr.us-east-1.amazonaws.com/amazon-k8s-cni-init@sha256:27aebe… |                                            | Pod:3       |            |          | 17m       |                 
  123456789012.dkr.ecr.us-east-1.amazonaws.com/amazon-k8s-cni@sha256:19dacc…      |                                            | Pod:3       |            |          | 17m       |                 
  123456789012.dkr.ecr.us-east-1.amazonaws.com/eks/coredns@sha256:e6a38c…         |                                            | Pod:2       |            |          | 17m       |                 
  123456789012.dkr.ecr.us-east-1.amazonaws.com/eks/kube-proxy@sha256:699b73…      |                                            | Pod:3       |            |          | 17m       |                 
  quay.io/cilium/cilium:v1.12.1@sha256:ea2db1…                                    |                                            | DaemonSet:1 |            |          | 17m       |                 
  quay.io/cilium/cilium@sha256:ea2db1…                                            |                                            | Pod:3       |            |          | 17m       |                 
  quay.io/cilium/hubble-relay:v1.12.1@sha256:646582…                              |                                            | Unknown:2   |            |          | 17m       |                 
  quay.io/cilium/hubble-relay@sha256:646582…                                      |                                            | Pod:1       |            |          | 17m       |                 
  quay.io/cilium/hubble-ui-backend:v0.9.1@sha256:c4b86e…                          |                                            | Unknown:2   |            |          | 17m       |                 
  quay.io/cilium/hubble-ui-backend@sha256:c4b86e…                                 |                                            | Unknown:1   |            |          | 17m       |                 
  quay.io/cilium/hubble-ui:v0.9.1@sha256:baff61…                                  |                                            | Unknown:2   |            |          | 17m       |                 
  quay.io/cilium/hubble-ui@sha256:baff61…                                         |                                            | Unknown:1   |            |          | 17m       |                 
  quay.io/cilium/operator-aws:v1.12.1@sha256:cbd071…                              |                                            | Unknown:2   |            |          | 17m       |                 
  quay.io/cilium/operator-aws@sha256:cbd071…                                      |                                            | Pod:2       |            |          | 17m       |                 
  quay.io/cilium/startup-script@sha256:0862c6…                                    |                                            | Pod:1       |            |          | 17m       |                 
                                                                                  |                                            | Unknown:2   |            |          |           |                 
  registry.k8s.io/ingress-nginx/controller-chroot:v1.5.1@sha256:c1c091…           |                                            | Unknown:2   |            |          | 17m       |                 
  registry.k8s.io/ingress-nginx/controller-chroot@sha256:c1c091…                  |                                            | Pod:1       |            |          | 17m       |                 
  us.gcr.io/prod-enforce-fabc/chainctl@sha256:86131b…                             |                                            | Pod:1       |            |          | 17m       |                 
                                                                                  |                                            | Unknown:2   |            |          |           |                 
  us.gcr.io/prod-enforce-fabc/controlplane@sha256:825856…                         |                                            | Pod:1       |            |          | 17m       |                 
                                                                                  |                                            | Unknown:2   |            |          |           |                 
```

Download the SBOM from the registry that was created by ko in the tekton pipeline 

```bash
cosign download sbom ghcr.io/chainguard-dev/tekton-demo:da09cbd --output-file sbom.json
```

Create and sign the attestation with cosign 

```bash
 cosign attest --predicate sbom.json --type spdxjson ghcr.io/chainguard-dev/tekton-demo:da09cbd
Generating ephemeral keys...
Retrieving signed certificate...

        Note that there may be personally identifiable information associated with this signed artifact.
        This may include the email address associated with the account with which you authenticate.
        This information will be used for signing this artifact and will be stored in public transparency logs and cannot be removed later.
        By typing 'y', you attest that you grant (or have permission to grant) and agree to have this information stored permanently in transparency logs.

Are you sure you want to continue? (y/[N]): y
Your browser will now be opened to:
https://oauth2.sigstore.dev/auth/auth?access_type=online&client_id=sigstore&code_challenge=k6RVkl9dkiA1QTJliSOMxlagVNDVaivVyM_l0g84Ims&code_challenge_method=S256&nonce=2IsECjRYPGlbm9vT3i10w8LQLFT&redirect_uri=http%3A%2F%2Flocalhost%3A39225%2Fauth%2Fcallback&response_type=code&scope=openid+email&state=2IsECgwifqsBWY0D8uByWJ9Q9Pl
Successfully verified SCT...
Using payload from: sbom.json
using ephemeral certificate:
-----BEGIN CERTIFICATE-----
MIICpzCCAi2gAwIBAgIUDCFrAdkXXwjHOhJ46tDnZ0xaOXswCgYIKoZIzj0EAwMw
NzEVMBMGA1UEChMMc2lnc3RvcmUuZGV2MR4wHAYDVQQDExVzaWdzdG9yZS1pbnRl
cm1lZGlhdGUwHhcNMjIxMjEzMjAwMjQ5WhcNMjIxMjEzMjAxMjQ5WjAAMFkwEwYH
KoZIzj0CAQYIKoZIzj0DAQcDQgAEIQI8mb7wkHUuKCY/0hNkcwy1Q4cju6ElB3Mb
QmACRFjWGQR/jzzuW4hcEyk4qZvos4E4fKks/KzB8kefIynj9KOCAUwwggFIMA4G
A1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEFBQcDAzAdBgNVHQ4EFgQUQ6il
1+4WQNmvK31cw2vh+L6XI1wwHwYDVR0jBBgwFoAU39Ppz1YkEZb5qNjpKFWixi4Y
ZD8wKQYDVR0RAQH/BB8wHYEbamFtZXMuc3Ryb25nQGNoYWluZ3VhcmQuZGV2MCkG
CisGAQQBg78wAQEEG2h0dHBzOi8vYWNjb3VudHMuZ29vZ2xlLmNvbTCBigYKKwYB
BAHWeQIEAgR8BHoAeAB2AN09MGrGxxEyYxkeHJlnNwKiSl643jyt/4eKcoAvKe6O
AAABhQ0VK2EAAAQDAEcwRQIhAIMl6P751P8lDuQP6aOQoWIuAKdtJUltKLgI28jX
OLx+AiB2BM7Bw1UbQfQZ3zOHKiCuy0egvjL6KLQbXhKuk55f3DAKBggqhkjOPQQD
AwNoADBlAjEAkmgqtLSu+u9jmwy6LHSIv5fkcvOZCv3P4SxEk/kcXgmFP9UWQA9h
AqUrTd7Lv0DFAjAPeBNeksffPLqvKjUmvFmtKIFM/jYiUCZs43swyjmwtFZMf6PQ
FVRm71aC1w03aXM=
-----END CERTIFICATE-----

tlog entry created with index: 9026108
```

The continuous verification of Chainguard Enforce for Kubernetes will rescan repositories every 10 minutes, we can update the policy to force a rescan.

You can read more about Continuous Verification on our [Academy Portal](https://edu.chainguard.dev/chainguard/chainguard-enforce/chainguard-enforce-kubernetes/understanding-continuous-verification/)

```bash
chainctl cluster records list tekton-demo-pov
                                       IMAGE                                      |                   POLICIES                   |  WORKLOADS  |  ANCESTRY  | PACKAGES | LAST SEEN | LAST REFRESHED  
----------------------------------------------------------------------------------+----------------------------------------------+-------------+------------+----------+-----------+-----------------                 
  ghcr.io/chainguard-dev/tekton-demo@sha256:aaa82b…                               | keyless-attestation-sbom:pass:7s             | Pod:1       | parents:1  | golang:1 | 22m       | sbom:7s         
                                                                                  | keyless-attestation-update:pass:6m14s        |             |            | oci:1    |           | sig:6m14s           
  123456789012.dkr.ecr.us-east-1.amazonaws.com/amazon-k8s-cni-init@sha256:27aebe… |                                              | Pod:3       |            |          | 26m       |                 
  123456789012.dkr.ecr.us-east-1.amazonaws.com/amazon-k8s-cni@sha256:19dacc…      |                                              | Pod:3       |            |          | 26m       |                 
  123456789012.dkr.ecr.us-east-1.amazonaws.com/eks/coredns@sha256:e6a38c…         |                                              | Pod:2       |            |          | 26m       |                 
  123456789012.dkr.ecr.us-east-1.amazonaws.com/eks/kube-proxy@sha256:699b73…      |                                              | Pod:3       |            |          | 26m       |                 
  quay.io/cilium/cilium:v1.12.1@sha256:ea2db1…                                    |                                              | DaemonSet:1 |            |          | 26m       |                 
  quay.io/cilium/cilium@sha256:ea2db1…                                            |                                              | Pod:3       |            |          | 26m       |                 
  quay.io/cilium/hubble-relay:v1.12.1@sha256:646582…                              |                                              | Unknown:2   |            |          | 26m       |                 
  quay.io/cilium/hubble-relay@sha256:646582…                                      |                                              | Pod:1       |            |          | 26m       |                 
  quay.io/cilium/hubble-ui-backend:v0.9.1@sha256:c4b86e…                          |                                              | Unknown:2   |            |          | 26m       |                 
  quay.io/cilium/hubble-ui-backend@sha256:c4b86e…                                 |                                              | Unknown:1   |            |          | 26m       |                 
  quay.io/cilium/hubble-ui:v0.9.1@sha256:baff61…                                  |                                              | Unknown:2   |            |          | 26m       |                 
  quay.io/cilium/hubble-ui@sha256:baff61…                                         |                                              | Unknown:1   |            |          | 26m       |                 
  quay.io/cilium/operator-aws:v1.12.1@sha256:cbd071…                              |                                              | Unknown:2   |            |          | 26m       |                 
  quay.io/cilium/operator-aws@sha256:cbd071…                                      |                                              | Pod:2       |            |          | 26m       |                 
  quay.io/cilium/startup-script@sha256:0862c6…                                    |                                              | Pod:1       |            |          | 26m       |                 
                                                                                  |                                              | Unknown:2   |            |          |           |                 
  registry.k8s.io/ingress-nginx/controller-chroot:v1.5.1@sha256:c1c091…           |                                              | Unknown:2   |            |          | 26m       |                 
  registry.k8s.io/ingress-nginx/controller-chroot@sha256:c1c091…                  |                                              | Pod:1       |            |          | 26m       |                 
  us.gcr.io/prod-enforce-fabc/chainctl@sha256:86131b…                             |                                              | Pod:1       |            |          | 26m       |                 
                                                                                  |                                              | Unknown:2   |            |          |           |                 
  us.gcr.io/prod-enforce-fabc/controlplane@sha256:825856…                         |                                              | Pod:1       |            |          | 26m       |                 
                                                                                  |                                              | Unknown:2   |            |          |           |             
```

