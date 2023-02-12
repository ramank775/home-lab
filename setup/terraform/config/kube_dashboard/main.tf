locals {
  namespace = "kubernetes-dashboard"
}

resource "kubernetes_manifest" "kube-dashboard-ingress-middleware" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "kube-strip-middleware-ingress"
      namespace = local.namespace
    }
    spec = {
      replacePathRegex = {
        regex       = "/dashboard/(.*)"
        replacement = "/$1"
      }
    }
  }
}
