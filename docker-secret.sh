#!/usr/bin/env bash

export GIT_USER="${GIT_USER}"
export GITHUB_TOKEN="${GITHUB_TOKEN}"
export GITHUB_EMAIL="${GITHUB_EMAIL}"


# KO and tekton-chains needs Github Token for upload
kubectl delete secrete github-token || true
kubectl create secret generic github-token --from-literal=GITHUB_TOKEN="${GITHUB_TOKEN}"

kubectl delete secret regcred || true
kubectl create secret docker-registry registry-credentials \
  --docker-server="ghcr.io" \
  --docker-username="${GIT_USER}" \
  --docker-password="${GITHUB_TOKEN}" \
  --docker-email="${GITHUB_EMAIL}"

kubectl patch serviceaccount default \
  -p "{\"imagePullSecrets\": [{\"name\": \"registry-credentials\"}]}" -n default

