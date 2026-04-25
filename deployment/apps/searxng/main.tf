resource "random_password" "searxng_secret_key" {
  length  = 16
  special = true
}


resource "helm_release" "searxng" {
  name             = "searxng"
  namespace        = var.namespace
  chart            = "searxng"
  repository       = "https://charts.kubito.dev"
  version          = var.chart_version
  create_namespace = true

  # Chart 1.1.0's Ingress template hardcodes the backend service name as
  # "searxng" but the Service is now named "searxng-http", producing a 404.
  # Disable the chart's Ingress and define our own below.
  set {
    name  = "ingress.enabled"
    value = false
  }
}

resource "kubernetes_ingress_v1" "searxng" {
  metadata {
    name      = "searxng"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class" = "traefik"
    }
  }

  spec {
    rule {
      host = var.domain

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "searxng-http"
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.searxng]
}
