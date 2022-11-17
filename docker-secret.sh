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
    tekton.dev/docker-0: https://ghcr.io
type: kubernetes.io/basic-auth
stringData:
  username: "${GITHUB_EMAIL}"
  password: "${GITHUB_TOKEN}"
EOF

kubectl delete secret regcred || true

kubectl create secret docker-registry regcred \
  --docker-server="ghcr.io" \
  --docker-username="strongjz" \
  --docker-password="${GITHUB_TOKEN}" \
  --docker-email="${GITHUB_EMAIL}"

kubectl apply -f secret.yaml -n default

kubectl patch serviceaccount default \
  -p "{\"imagePullSecrets\": [{\"name\": \"ghcr-secret\"},{\"name\": \"regcred\"}]}" -n default

kubectl patch serviceaccount build-bot \
  -p "{\"imagePullSecrets\": [{\"name\": \"ghcr-secret\"}]}" -n default

rm secret.yaml
