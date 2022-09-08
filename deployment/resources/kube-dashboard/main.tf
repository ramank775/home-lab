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

resource "kubernetes_service" "kube-dashboard-service" {
  metadata {
    name      = "kube-dashboard-service"
    namespace = local.namespace
    annotations = {
      "traefik.ingress.kubernetes.io/service.serverstransport" = "kube-system-traefix-insecure-server-transport@kubernetescrd"
      "traefik.ingress.kubernetes.io/service.serversscheme"    = "https"
    }
  }
  spec {
    type = "ClusterIP"
    port {
      port        = 443
      target_port = 8443
      protocol    = "TCP"
    }
    selector = {
      "k8s-app" = "kubernetes-dashboard"
    }
  }
}

resource "kubernetes_ingress_v1" "kube-dashboard-ingress" {
  metadata {
    name      = "kube-dashboard-ingress"
    namespace = local.namespace
    annotations = {
      "kubernetes.io/ingress.class"                            = "traefik"
      "traefik.ingress.kubernetes.io/router.middlewares"       = "kubernetes-dashboard-kube-strip-middleware-ingress@kubernetescrd"
      "traefik.ingress.kubernetes.io/service.serverstransport" = "kube-system-traefix-insecure-server-transport@kubernetescrd"
      "traefik.ingress.kubernetes.io/service.serversscheme"    = "https"
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
              name = "kube-dashboard-service"
              port {
                number = 443
              }
            }
          }
        }
      }
    }
  }
}
