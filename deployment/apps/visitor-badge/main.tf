locals {
  image       = "${var.image}:${var.tag}"
  appname     = "visitor-badge"
  replicas    = var.replicas
  data_volume = "visitor-badge-redis-data"
}

resource "kubernetes_persistent_volume_claim" "redis_data_volume" {
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
        "storage" = "1Gi"
      }
    }
    storage_class_name = "truenas-iscsi-csi"
    access_modes       = ["ReadWriteOnce"]
  }
}

resource "kubernetes_service" "redis-service" {
  metadata {
    name = "${local.appname}-redis-service"
    namespace = var.namespace
    labels = {
      app = "${local.appname}-redis-service"
    }
  }
  spec {
    type = "ClusterIP"
    port {
      name = "redis"
      port = 6379
      target_port = 6379
    }
    selector = {
      app = "${local.appname}-redis"
    }
  }
}

resource "kubernetes_stateful_set_v1" "redis" {
  metadata {
    name      = "${local.appname}-redis"
    namespace = var.namespace
    labels = {
      app = "${local.appname}-redis"
    }
  }

  spec {
    replicas = var.replicas
    selector {
      match_labels = {
        app = "${local.appname}-redis"
      }
    }
    service_name = "${local.appname}-redis-service"
    template {
      metadata {
        labels = {
          app = "${local.appname}-redis"
        }
      }
      spec {
        container {
          name              = "${local.appname}-redis"
          image             = "redis:alpine"
          image_pull_policy = "Always"
          volume_mount {
            name       = "data"
            mount_path = "/data"
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
resource "kubernetes_deployment" "visitor_badge_deployement" {
  metadata {
    name      = local.appname
    namespace = var.namespace
    labels = {
      "app" = local.appname
    }
  }

  spec {
    replicas = local.replicas
    selector {
      match_labels = {
        "app" = local.appname
      }
    }
    template {
      metadata {
        labels = {
          "app" = local.appname
        }
      }

      spec {
        container {
          name = local.appname
          resources {
            limits = {
              "memory" = var.memorylimit
            }
          }
          image             = local.image
          image_pull_policy = "IfNotPresent"

          env {
            name  = "md5_key"
            value = "guess_what"
          }

          env {
            name  = "redis_host"
            value = "${local.appname}-redis-service"
          }

          port {
            container_port = 5000
            protocol       = "TCP"
          }

        }
        node_selector = var.node_selector
      }
    }

  }
}

resource "kubernetes_service" "visitor_badge_service" {
  metadata {
    name      = local.appname
    namespace = var.namespace
    labels = {
      "app" = local.appname
    }
  }

  spec {
    type = "ClusterIP"
    selector = {
      "app" = local.appname
    }
    port {
      name        = "endpoint"
      port        = 80
      target_port = 5000
      protocol    = "TCP"
    }
  }
}
