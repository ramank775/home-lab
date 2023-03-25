locals {
  data_volume = "vaultwarden-data"
  app         = "vaultwarden"
  replicas    = 1
}

resource "kubernetes_persistent_volume_claim" "vaultwarden_data" {
  metadata {
    name      = local.data_volume
    namespace = var.namespace
    labels = {
      "app" = local.data_volume
    }
  }
  wait_until_bound = false
  spec {
    resources {
      requests = {
        "storage" = "5Gi"
      }
    }
    storage_class_name = "truenas-iscsi-csi"
    access_modes       = ["ReadWriteOnce"]
  }
}

resource "kubernetes_deployment" "vaultwarden" {
  metadata {
    name      = local.app
    namespace = var.namespace
    labels = {
      "app" = local.app
    }
  }
  spec {
    replicas = local.replicas
    selector {
      match_labels = {
        "app" = local.app
      }
    }
    template {
      metadata {
        labels = {
          "app" = local.app
        }
      }
      spec {
        container {
          name              = local.app
          image_pull_policy = "Always"
          image             = "vaultwarden/server"
          env {
            name  = "WEBSOCKET_ENABLED"
            value = "true"
          }

          env {
            name  = "SIGNUPS_ALLOWED"
            value = "false"
          }

          port {
            container_port = 80
          }
          port {
            container_port = 3012
          }
          volume_mount {
            mount_path = "/data"
            name       = "data"
          }
        }
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = local.data_volume
          }
        }
      }

    }
  }
}

resource "kubernetes_service" "vaultwarden_service" {
  metadata {
    name      = local.app
    namespace = var.namespace
    labels = {
      "app" = local.app
    }
  }
  spec {
    type = "ClusterIP"
    selector = {
      app = local.app
    }
    port {
      name        = "endpoint"
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }
    port {
      name        = "websocket"
      port        = 3012
      target_port = 3012
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_ingress_v1" "name" {
  metadata {
    name      = "${local.app}-ingress"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class"                      = "traefik"
      "traefik.ingress.kubernetes.io/router.middlewares" = "kube-system-redirect@kubernetescrd"
    }
  }
  spec {
    rule {
      host = var.domain
      http {
        path {
          path = "/notifications/hub"
          backend {
            service {
              name = local.app
              port {
                number = 3012
              }
            }
          }
        }
        path {
          path = "/"
          backend {
            service {
              name = local.app
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
