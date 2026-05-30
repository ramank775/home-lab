locals {
  appname = "cloudbeaver"
}

resource "kubernetes_persistent_volume_claim" "workspace" {
  metadata {
    name      = "${local.appname}-workspace"
    namespace = var.namespace
    labels = {
      app = local.appname
    }
  }
  wait_until_bound = true
  spec {
    resources {
      requests = {
        "storage" = var.storage_size
      }
    }
    storage_class_name = var.storage_class
    access_modes       = ["ReadWriteOnce"]
  }
}

resource "kubernetes_deployment" "cloudbeaver" {
  metadata {
    name      = local.appname
    namespace = var.namespace
    labels = {
      app = local.appname
    }
  }

  spec {
    replicas = 1

    strategy {
      type = "Recreate"
    }

    selector {
      match_labels = {
        app = local.appname
      }
    }

    template {
      metadata {
        labels = {
          app = local.appname
        }
      }

      spec {
        # CloudBeaver only publishes amd64 images.
        node_selector = {
          "kubernetes.io/arch" = "amd64"
        }

        container {
          name  = local.appname
          image = "${var.image_repo}:${var.image_tag}"

          port {
            container_port = 8978
          }

          volume_mount {
            name       = "workspace"
            mount_path = "/opt/cloudbeaver/workspace"
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 8978
            }
            initial_delay_seconds = 20
            period_seconds        = 10
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 8978
            }
            initial_delay_seconds = 60
            period_seconds        = 30
          }
        }

        volume {
          name = "workspace"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.workspace.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "cloudbeaver" {
  metadata {
    name      = local.appname
    namespace = var.namespace
    labels = {
      app = local.appname
    }
  }

  spec {
    selector = {
      app = local.appname
    }

    port {
      name        = "http"
      port        = 80
      target_port = 8978
    }
  }
}

resource "kubernetes_ingress_v1" "cloudbeaver" {
  metadata {
    name      = local.appname
    namespace = var.namespace
  }

  spec {
    rule {
      host = var.domain

      http {
        path {
          path = "/"

          backend {
            service {
              name = kubernetes_service.cloudbeaver.metadata[0].name
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
