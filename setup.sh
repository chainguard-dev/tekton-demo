#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

THIS_OS="$(uname -s)"
THIS_HW="$(uname -m)"

RUNNING_ON_MAC="false"
RUNNING_ON_WINDOWS="false"
RUNNING_ON_LINUX="true"
# We need to do couple of things different on Mac
if [ "${THIS_OS}" == "Darwin" ]; then
  echo "Running on Mac"
  RUNNING_ON_MAC="true"
  RUNNING_ON_LINUX="false"
fi
# We need to do couple of things different on Windows running WSL.
if uname -r | grep --quiet microsoft ; then
  echo "Running on Windows"
  RUNNING_ON_WINDOWS="true"
  RUNNING_ON_LINUX="false"
fi

TEKTON_CHAINS_RELEASE="https://storage.googleapis.com/tekton-releases/chains/latest/release.yaml"
TEKTON_PIPELINES_RELEASE="https://storage.googleapis.com/tekton-releases-nightly/pipeline/latest/release.yaml"
TEKTON_DASHBOARD_RELEASE="https://storage.googleapis.com/tekton-releases/dashboard/latest/tekton-dashboard-release.yaml"

# Defaults
K8S_VERSION="v1.23.x"
REGISTRY_NAME="registry.local"
REGISTRY_PORT="5000"
CLUSTER_SUFFIX="cluster.local"
NODE_COUNT="2"
KIND_CLUSTER_NAME="tekton"
while [[ $# -ne 0 ]]; do
  parameter="$1"
  case "${parameter}" in
    --k8s-version)
      shift
      K8S_VERSION="$1"
      ;;
    --knative-version)
      shift
      KNATIVE_VERSION="$1"
      ;;
    --registry-url)
      shift
      REGISTRY_NAME="$(echo "$1" | cut -d':' -f 1)"
      REGISTRY_PORT="$(echo "$1" | cut -d':' -f 2)"
      ;;
    --cluster-suffix)
      shift
      CLUSTER_SUFFIX="$1"
      ;;
    *) echo "unknown option ${parameter}"; exit 1 ;;
  esac
  shift
done

docker stop "${REGISTRY_NAME}" && docker rm "${REGISTRY_NAME}"

# The version map correlated with this version of KinD
KIND_VERSION="v0.17.0"
case ${K8S_VERSION} in
  v1.23.x)
    K8S_VERSION="1.23.13"
    KIND_IMAGE_SHA="sha256:ef453bb7c79f0e3caba88d2067d4196f427794086a7d0df8df4f019d5e336b61"
    KIND_IMAGE="kindest/node:${K8S_VERSION}@${KIND_IMAGE_SHA}"
    ;;
  v1.24.x)
    K8S_VERSION="1.24.7"
    KIND_IMAGE_SHA="sha256:577c630ce8e509131eab1aea12c022190978dd2f745aac5eb1fe65c0807eb315"
    KIND_IMAGE="kindest/node:${K8S_VERSION}@${KIND_IMAGE_SHA}"
    ;;
  v1.25.x)
    K8S_VERSION="1.25.3"
    KIND_IMAGE_SHA="sha256:f52781bc0d7a19fb6c405c2af83abfeb311f130707a0e219175677e366cc45d1"
    KIND_IMAGE="kindest/node:${K8S_VERSION}@${KIND_IMAGE_SHA}"
    ;;
  *) echo "Unsupported version: ${K8S_VERSION}"; exit 1 ;;
esac

#############################################################
#
#    Install KinD
#
#############################################################
echo '::group:: Install KinD'

EXTRA_MOUNT=""
# This does not work on Mac, or Windows so skip.
if [ ${RUNNING_ON_LINUX} == "true" ]; then
  # Disable swap otherwise memory enforcement does not work
  # See: https://kubernetes.slack.com/archives/CEKK1KTN2/p1600009955324200
  sudo swapoff -a
  sudo rm -f /swapfile
  # Use in-memory storage to avoid etcd server timeouts.
  # https://kubernetes.slack.com/archives/CEKK1KTN2/p1615134111016300
  # https://github.com/kubernetes-sigs/kind/issues/845
  sudo mkdir -p /tmp/etcd
  sudo mount -t tmpfs tmpfs /tmp/etcd
fi

if ! command -v kind &> /dev/null; then
  echo ":: Installing Kind ::"
  curl -Lo ./kind "https://github.com/kubernetes-sigs/kind/releases/download/${KIND_VERSION}/kind-$(uname)-$(THIS_HW)"
  chmod +x ./kind
  sudo mv kind /usr/local/bin
fi

echo '::endgroup::'

#############################################################
#
#    Setup KinD cluster.
#
#############################################################
echo '::group:: Build KinD Config'

if [ ${RUNNING_ON_LINUX} == "true" ]; then
  cat > kind.yaml <<EOF_LINUX
apiVersion: kind.x-k8s.io/v1alpha4
kind: Cluster
name: ${KIND_CLUSTER_NAME}
nodes:
- role: control-plane
  image: "${KIND_IMAGE}"
  extraMounts:
  - containerPath: /var/lib/etcd
    hostPath: /tmp/etcd
- role: worker
  image: "${KIND_IMAGE}"
EOF_LINUX
fi

if [ ${RUNNING_ON_MAC} == "true" ]; then
  cat > kind.yaml <<EOF_MAC
apiVersion: kind.x-k8s.io/v1alpha4
kind: Cluster
name: ${KIND_CLUSTER_NAME}
nodes:
- role: control-plane
  image: "${KIND_IMAGE}"
- role: worker
  image: "${KIND_IMAGE}"
EOF_MAC
fi

if [ ${RUNNING_ON_WINDOWS} == "true" ]; then
  cat > kind.yaml <<EOF_WINDOWS
apiVersion: kind.x-k8s.io/v1alpha4
kind: Cluster
name: ${KIND_CLUSTER_NAME}
nodes:
- role: control-plane
  image: "${KIND_IMAGE}"
- role: worker
  image: "${KIND_IMAGE}"
EOF_WINDOWS
fi

cat >> kind.yaml <<EOF_SHARED
# Configure registry for KinD.
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."$REGISTRY_NAME:$REGISTRY_PORT"]
    endpoint = ["http://$REGISTRY_NAME:$REGISTRY_PORT"]

# This is needed in order to support projected volumes with service account tokens.
# See: https://kubernetes.slack.com/archives/CEKK1KTN2/p1600268272383600
kubeadmConfigPatches:
  - |
    apiVersion: kubeadm.k8s.io/v1beta2
    kind: ClusterConfiguration
    metadata:
      name: config
    apiServer:
      extraArgs:
        "service-account-issuer": "https://kubernetes.default.svc"
        "service-account-key-file": "/etc/kubernetes/pki/sa.pub"
        "service-account-signing-key-file": "/etc/kubernetes/pki/sa.key"
        "service-account-api-audiences": "api,spire-server"
        "service-account-jwks-uri": "https://kubernetes.default.svc/openid/v1/jwks"
    networking:
      dnsDomain: "${CLUSTER_SUFFIX}"
EOF_SHARED

cat kind.yaml
echo '::endgroup::'

kind delete cluster --name "${KIND_CLUSTER_NAME}"
echo '::group:: Create KinD Cluster'
kind create cluster --config kind.yaml --wait 5m

kubectl describe nodes
echo '::endgroup::'

echo '::group:: Expose OIDC Discovery'

# From: https://banzaicloud.com/blog/kubernetes-oidc/
# To be able to fetch the public keys and validate the JWT tokens against
# the Kubernetes cluster’s issuer we have to allow external unauthenticated
# requests. To do this, we bind this special role with a ClusterRoleBinding
# to unauthenticated users (make sure that this is safe in your environment,
# but only public keys are visible on this URL)
kubectl create clusterrolebinding oidc-reviewer \
  --clusterrole=system:service-account-issuer-discovery \
  --group=system:unauthenticated

echo '::endgroup::'


#############################################################
#
#    Setup metallb
#
#############################################################
echo '::group:: Setup metallb'

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"

network=$(docker network inspect kind -f "{{(index .IPAM.Config 0).Subnet}}" | cut -d '.' -f1,2)
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - $network.255.1-$network.255.250
EOF

echo '::endgroup::'


#############################################################
#
#    Setup container registry
#
#############################################################
echo '::group:: Setup container registry'


docker run -d --restart=always \
       -p "$REGISTRY_PORT:$REGISTRY_PORT" --name "$REGISTRY_NAME" registry:2

# Connect the registry to the KinD network.
docker network connect "kind" "$REGISTRY_NAME"

# Make the $REGISTRY_NAME -> 127.0.0.1, to tell `ko` to publish to
# local reigstry, even when pushing $REGISTRY_NAME:$REGISTRY_PORT/some/image
sudo echo "127.0.0.1 $REGISTRY_NAME" | sudo tee -a /etc/hosts

echo '::endgroup::'

echo '::group:: Install Tekton Pipelines and chains'
while ! kubectl apply --filename "${TEKTON_PIPELINES_RELEASE}"
do
  echo "waiting for tekton pipelines to get installed"
  sleep 2
done

# Disable affinity-assistance so that we can mount multiple volumes for in/out
kubectl patch configmap/feature-flags \
--namespace tekton-pipelines \
--type merge \
--patch '{"data":{"disable-affinity-assistant": "true"}}'

# Restart so picks up the changes.
kubectl -n tekton-pipelines delete po -l app=tekton-pipelines-controller || true

while ! kubectl apply --filename "${TEKTON_CHAINS_RELEASE}"
do
  echo "waiting for tekton chains to get installed"
  sleep 2
done

kubectl patch configmap/chains-config \
--namespace tekton-chains \
--type merge \
--patch '{"data":{"artifacts.oci.format": "simplesigning", "artifacts.oci.storage": "oci", "artifacts.taskrun.format": "in-toto", "signers.x509.fulcio.address": "https://fulcio.sigstore.dev", "signers.x509.fulcio.enabled": "true", "transparency.enabled": "true", "transparency.url": "https://rekor.sigstore.dev"}}'

# Restart so picks up the changes.
kubectl -n tekton-chains delete po -l app=tekton-chains-controller

while ! kubectl apply --filename "${TEKTON_DASHBOARD_RELEASE}"
do
  echo "waiting for tekton dashboard to get installed"
  sleep 2
done
echo '::endgroup::'