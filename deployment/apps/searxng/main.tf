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

  # Pin the upstream image tag; the chart otherwise defaults to "latest".
  set {
    name  = "image.tag"
    value = var.image_tag
  }

  # NOTE: chart 1.1.4 already enables the JSON search format by default
  # (config.settings.data ships formats: [html, json]), which the mcp-searxng
  # server needs. No override required. If config.settings.data is ever
  # customized, it's one opaque string — preserve `json` under search.formats.
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
