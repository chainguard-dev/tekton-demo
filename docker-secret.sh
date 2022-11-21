#!/usr/bin/env bash

export GIT_USER="${GIT_USER}"
export GITHUB_TOKEN="${GITHUB_TOKEN}"
export GITHUB_EMAIL="${GITHUB_EMAIL}"

kubectl delete secret regcred || true

kubectl create secret docker-registry regcred \
  --docker-server="ghcr.io" \
  --docker-username="${GIT_USER}" \
  --docker-password="${GITHUB_TOKEN}" \
  --docker-email="${GITHUB_EMAIL}"

kubectl patch serviceaccount default \
  -p "{\"imagePullSecrets\": [{\"name\": \"regcred\"}]}" -n default

kubectl patch serviceaccount build-bot \
  -p "{\"imagePullSecrets\": [{\"name\": \"regcred\"}]}" -n default

kubectl delete secret github-token || true
kubectl create secret generic github-token --from-literal=GITHUB_TOKEN="${GITHUB_TOKEN}"
