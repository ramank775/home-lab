resource "kubernetes_ingress_v1" "longhorn-ingress" {
  metadata {
    name      = "longhorn-ingress"
    namespace = "longhorn-system"
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
