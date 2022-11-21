#resource "helm_release" "ingress" {
#  chart            = "ingress-nginx"
#  name             = "ingress-nginx"
#  repository       = "https://kubernetes.github.io/ingress-nginx"
#  namespace        = "ingress-nginx"
#  create_namespace = true
#
#  values = [
#    file("${path.module}/ingress.yaml")
#  ]
#}
