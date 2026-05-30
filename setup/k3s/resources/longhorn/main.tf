locals {
  namespace = "longhorn-system"
}

resource "kubernetes_namespace" "longhorn-namespace" {
  metadata {
    name = local.namespace
  }
}

resource "helm_release" "longhorn" {
  depends_on = [
    kubernetes_namespace.longhorn-namespace
  ]
  name       = "longhorn"
  repository = "https://charts.longhorn.io"
  chart      = "longhorn"
  namespace  = local.namespace
  version    = var.chart_version
}

resource "kubernetes_ingress_v1" "longhorn-ingress" {
  depends_on = [
    kubernetes_namespace.longhorn-namespace
  ]
  metadata {
    name      = "longhorn-ingress"
    namespace = local.namespace
    annotations = {
      "kubernetes.io/ingress.class" = "traefik"
    }
  }
  spec {
    rule {
      host = var.domain
      http {
        path {
          path = "/"
          backend {
            service {
              name = "longhorn-frontend"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
