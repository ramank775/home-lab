locals {
  appname = "listmonk"
}

resource "random_password" "db_passwd" {
  length  = 24
  special = false
}

resource "postgresql_role" "db_user" {
  name     = local.appname
  login    = true
  password = random_password.db_passwd.result
}

resource "postgresql_database" "listmonk_db" {
  name                   = local.appname
  owner                  = postgresql_role.db_user.name
  template               = "template0"
  lc_collate             = "C"
  connection_limit       = -1
  allow_connections      = true
  alter_object_ownership = true
  depends_on             = [postgresql_role.db_user]
}

resource "kubernetes_persistent_volume_claim_v1" "listmonk_uploads" {
  metadata {
    name      = "${local.appname}-uploads"
    namespace = var.namespace
    labels = {
      app = local.appname
    }
  }
  wait_until_bound = true
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

locals {
  listmonk_env = [
    { name = "LISTMONK_app__address", value = "0.0.0.0:9000" },
    { name = "LISTMONK_db__host", value = var.database.host },
    { name = "LISTMONK_db__port", value = tostring(var.database.port) },
    { name = "LISTMONK_db__user", value = postgresql_role.db_user.name },
    { name = "LISTMONK_db__password", value = random_password.db_passwd.result },
    { name = "LISTMONK_db__database", value = local.appname },
    { name = "LISTMONK_db__ssl_mode", value = "disable" },
    { name = "LISTMONK_ADMIN_USER", value = var.admin.username },
    { name = "LISTMONK_ADMIN_PASSWORD", value = var.admin.password },
  ]
}

resource "kubernetes_deployment_v1" "listmonk_app" {
  depends_on = [
    postgresql_database.listmonk_db,
  ]

  metadata {
    name      = local.appname
    namespace = var.namespace
    labels = {
      app = local.appname
    }
  }

  spec {
    replicas = var.replicas

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
        init_container {
          name              = "install"
          image             = "${var.image_repo}:${var.image_tag}"
          image_pull_policy = "IfNotPresent"
          command           = ["./listmonk", "--install", "--idempotent", "--yes"]

          dynamic "env" {
            for_each = local.listmonk_env
            content {
              name  = env.value.name
              value = env.value.value
            }
          }
        }

        init_container {
          name              = "upgrade"
          image             = "${var.image_repo}:${var.image_tag}"
          image_pull_policy = "IfNotPresent"
          command           = ["./listmonk", "--upgrade", "--yes"]

          dynamic "env" {
            for_each = local.listmonk_env
            content {
              name  = env.value.name
              value = env.value.value
            }
          }
        }

        container {
          name              = local.appname
          image             = "${var.image_repo}:${var.image_tag}"
          image_pull_policy = "IfNotPresent"

          dynamic "env" {
            for_each = local.listmonk_env
            content {
              name  = env.value.name
              value = env.value.value
            }
          }

          port {
            container_port = 9000
          }

          volume_mount {
            name       = "uploads"
            mount_path = "/listmonk/uploads"
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 9000
            }
            initial_delay_seconds = 15
            period_seconds        = 10
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 9000
            }
            initial_delay_seconds = 60
            period_seconds        = 30
          }
        }

        volume {
          name = "uploads"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.listmonk_uploads.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "listmonk_app" {
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
      target_port = 9000
    }
  }
}

resource "kubernetes_ingress_v1" "listmonk_app" {
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
              name = kubernetes_service_v1.listmonk_app.metadata[0].name
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
