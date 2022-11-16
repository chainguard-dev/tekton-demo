#!/usr/bin/env bash


kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  serviceAccountName: default
  containers:
    - image: nginx:alpine
      name: oidc
      volumeMounts:
      - name: oidc-info
        mountPath: /var/run/sigstore/cosign
  volumes:
  - name: oidc-info
    projected:
      sources:
        - serviceAccountToken:
            path: oidc-token
            expirationSeconds: 600 # Use as short-lived as possible.
            audience: sigstore
EOF