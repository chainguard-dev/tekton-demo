#!/usr/bin/env bash

export GIT_USER="${GIT_USER}"
export GITHUB_TOKEN="${GITHUB_TOKEN}"
export GITHUB_EMAIL="${GITHUB_EMAIL}"


kubectl delete secret ghcr-secret || true

cat > secret.yaml << EOF
apiVersion: v1
kind: Secret
metadata:
  name: ghcr-secret
  annotations:
    tekton.dev/git-0: https://github.com
    tekton.dev/git-1: https://gitlab.com
    tekton.dev/docker-0: https://ghcr.io
type: kubernetes.io/basic-auth
stringData:
  username: ${GITHUB_EMAIL}"
  password: ${GITHUB_TOKEN}"
EOF

kubectl apply -f secret.yaml -n default
kubectl apply -f secret.yaml -n tekton-pipelines
kubectl apply -f secret.yaml -n tekton-chains

kubectl patch serviceaccount tekton-chains-controller \
  -p "{\"imagePullSecrets\": [{\"name\": \"ghcr-secret\"}]}" -n tekton-chains

kubectl patch serviceaccount default \
  -p "{\"imagePullSecrets\": [{\"name\": \"ghcr-secret\"}]}" -n default

kubectl patch serviceaccount build-bot \
  -p "{\"imagePullSecrets\": [{\"name\": \"ghcr-secret\"}]}" -n default

kubectl -n tekton-chains delete po -l app=tekton-chains-controller

rm secret.yaml
