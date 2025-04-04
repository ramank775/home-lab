locals {
  namespace = "kube-system"
}

resource "kubernetes_manifest" "traefix-insecure-server-transport" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "ServersTransport"
    metadata = {
      name      = "traefix-insecure-server-transport"
      namespace = local.namespace
    }
    spec = {
      insecureSkipVerify = true
    }
  }
}

resource "kubernetes_service" "traefix-dashboard-service" {
  metadata {
    name      = "traefik-dashboard"
    namespace = local.namespace
    labels = {
      "app.kubernetes.io/instance" = "traefik"
      "app.kubernetes.io/name"     = "traefik-dashboard"
    }
  }
  spec {
    type = "ClusterIP"
    port {
      name        = "traefik"
      port        = 8080
      target_port = "traefik"
      protocol    = "TCP"
    }
    selector = {
      "app.kubernetes.io/instance" = "traefik-kube-system"
      "app.kubernetes.io/name"     = "traefik"
    }
  }
}

resource "kubernetes_manifest" "https-redirect-middleware" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "redirect"
      namespace = local.namespace
    }
    spec = {
      redirectScheme = {
        scheme    = "https"
        permanent = "true"
      }
    }
  }
}

resource "kubernetes_ingress_v1" "traefik-ingress" {
  metadata {
    name      = "traefik-ingress"
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
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "traefik-dashboard"
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
  }
}
