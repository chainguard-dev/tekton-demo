resource "helm_release" "cilium" {
  # https://github.com/cilium/cilium/tree/v1.12.1/install/kubernetes/cilium
  name             = "cilium"
  depends_on       = [module.eks]
  repository       = "https://helm.cilium.io/"
  chart            = "cilium"
  version          = "1.12.1"
  namespace        = "kube-system"
  create_namespace = false
  force_update     = true
  recreate_pods    = true
  cleanup_on_fail  = true
  replace          = true
  set {
    name  = "eni.enabled"
    value = "true"
  }
  set {
    name  = "ipam.mode"
    value = "eni"
  }
  set {
    name  = "egressMasqueradeInterfaces"
    value = "eth0"
  }

  set {
    name  = "tunnel"
    value = "disabled"
  }
  set {
    name  = "nodeinit.enabled"
    value = "true"
  }
  set {
    name  = "hubble.listenAddress="
    value = ":4244"
  }
  set {
    name  = "hubble.relay.enabled"
    value = "true"
  }
  set {
    name  = "hubble.ui.enabled"
    value = "true"
  }
}

# Scale the aws cni down https://docs.cilium.io/en/v1.9/gettingstarted/k8s-install-eks/
#kubectl patch daemonset aws-node -n kube-system -p '{"spec":{"template":{"spec":{"nodeSelector":{"no-such-node": "true"}}}}}'
#kubectl patch daemonset kube-proxy -n kube-system -p '{"spec":{"template":{"spec":{"nodeSelector":{"no-such-node": "true"}}}}}'
#kubectl scale deployment coredns --replicas=0 -n kube-system

# Then Scale back up
# kubectl scale deployment coredns --replicas=2 -n kube-system
