locals {
  appname = "postiz"
}


resource "random_password" "db_passwd" {
  length  = 16
  special = true
}


resource "postgresql_role" "db_user" {
  name     = local.appname
  login    = true
  password = random_password.db_passwd.result
}

resource "postgresql_database" "postiz_db" {
  name                   = local.appname
  owner                  = postgresql_role.db_user.name
  template               = "template0"
  lc_collate             = "C"
  connection_limit       = -1
  allow_connections      = true
  alter_object_ownership = true
  depends_on             = [postgresql_role.db_user]
}


resource "kubernetes_service" "redis-service" {
  metadata {
    name      = "${local.appname}-redis-service"
    namespace = var.namespace
    labels = {
      app = "${local.appname}-redis-service"
    }
  }
  spec {
    type = "ClusterIP"
    port {
      name        = "redis"
      port        = 6379
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
    replicas = 1
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
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "postiz_data" {
  metadata {
    name      = "postiz-data"
    namespace = var.namespace
    labels = {
      "app" = local.appname
    }
  }
  wait_until_bound = true
  spec {
    resources {
      requests = {
        "storage" = "30Gi"
      }
    }
    storage_class_name = "truenas-iscsi-csi"
    access_modes       = ["ReadWriteOnce"]
  }
}

resource "random_password" "jwt_secret" {
  length  = 16
  special = true
}

resource "kubernetes_secret" "social_app_config" {
  metadata {
    name      = "postiz-social-app-config"
    namespace = var.namespace
  }

  data = jsondecode(file(var.social_app_config))
  type = "Opaque"

}

resource "kubernetes_deployment" "postiz_app" {
  metadata {
    name      = local.appname
    namespace = var.namespace
    labels = {
      app = local.appname
    }
  }

  spec {
    replicas = var.replicas

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
        container {
          name  = "postiz"
          image = "${var.image_repo}:${var.image_tag}"

          env {
            name  = "MAIN_URL"
            value = "https://${var.domain}"
          }

          env {
            name  = "FRONTEND_URL"
            value = "https://${var.domain}"
          }

          env {
            name  = "NEXT_PUBLIC_BACKEND_URL"
            value = "https://${var.domain}/api"
          }

          env {
            name  = "JWT_SECRET"
            value = random_password.jwt_secret.result
          }

          env {
            name  = "DATABASE_URL"
            value = "postgresql://${postgresql_role.db_user.name}:${random_password.db_passwd.result}@${var.database.host}:${var.database.port}/${local.appname}"
          }

          env {
            name  = "REDIS_URL"
            value = "redis://${local.appname}-redis-service:6379"
          }

          env {
            name  = "BACKEND_INTERNAL_URL"
            value = "http://localhost:3000"
          }

          env {
            name  = "IS_GENERAL"
            value = "true"
          }

          env {
            name  = "STORAGE_PROVIDER"
            value = "local"
          }

          env {
            name  = "UPLOAD_DIRECTORY"
            value = "/uploads"
          }

          env {
            name  = "NEXT_PUBLIC_UPLOAD_DIRECTORY"
            value = "/uploads"
          }

          env {
            name  = "DISABLE_REGISTRATION"
            value = "true"
          }

          env {
            name  = "EMAIL_PROVIDER"
            value = "nodemailer"
          }

          env {
            name  = "EMAIL_FROM_NAME"
            value = "Postiz"
          }

          env {
            name  = "EMAIL_FROM_ADDRESS"
            value = var.email.address
          }

          env {
            name  = "EMAIL_HOST"
            value = var.smtp.host
          }

          env {
            name  = "EMAIL_PORT"
            value = var.smtp.port
          }

          env {
            name  = "EMAIL_SECURE"
            value = var.smtp.security == "on" ? "true" : "false"
          }

          env {
            name  = "EMAIL_USER"
            value = var.email.user
          }
          env {
            name  = "EMAIL_PASS"
            value = var.email.pass
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.social_app_config.metadata[0].name
            }
          }

          port {
            container_port = 5000
          }

          volume_mount {
            name       = "uploads"
            mount_path = "/uploads"
          }
        }

        volume {
          name = "uploads"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.postiz_data.metadata[0].name
          }
        }
      }
    }
  }
}
resource "kubernetes_service" "postiz_app" {
  metadata {
    name = local.appname
    labels = {
      app = local.appname
    }
    namespace = var.namespace
  }

  spec {
    selector = {
      app = local.appname
    }

    port {
      name        = "http"
      port        = 80
      target_port = 5000
    }
  }
}

resource "kubernetes_ingress_v1" "postiz_app" {
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
              name = kubernetes_service.postiz_app.metadata[0].name
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
