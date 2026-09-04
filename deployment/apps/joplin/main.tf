locals {
  appname = "joplin"
}

resource "random_password" "db_passwd" {
  length  = 16
  special = false
}

resource "postgresql_role" "db_user" {
  name     = local.appname
  login    = true
  password = random_password.db_passwd.result
}

resource "postgresql_database" "joplin_db" {
  name                   = local.appname
  owner                  = postgresql_role.db_user.name
  template               = "template0"
  lc_collate             = "C"
  connection_limit       = -1
  allow_connections      = true
  alter_object_ownership = true
  depends_on             = [postgresql_role.db_user]
}

resource "kubernetes_deployment_v1" "joplin_app" {
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
        container {
          name  = "joplin"
          image = "${var.image_repo}:${var.image_tag}"

          env {
            name  = "APP_BASE_URL"
            value = "https://${var.domain}"
          }

          env {
            name  = "APP_PORT"
            value = "22300"
          }

          env {
            name  = "DB_CLIENT"
            value = "pg"
          }

          env {
            name  = "POSTGRES_HOST"
            value = var.database.host
          }

          env {
            name  = "POSTGRES_PORT"
            value = var.database.port
          }

          env {
            name  = "POSTGRES_DATABASE"
            value = local.appname
          }

          env {
            name  = "POSTGRES_USER"
            value = postgresql_role.db_user.name
          }

          env {
            name  = "POSTGRES_PASSWORD"
            value = random_password.db_passwd.result
          }

          env {
            name  = "MAILER_ENABLED"
            value = "1"
          }

          env {
            name  = "MAILER_HOST"
            value = var.smtp.host
          }

          env {
            name  = "MAILER_PORT"
            value = var.smtp.port
          }

          env {
            name  = "MAILER_SECURITY"
            value = coalesce(var.smtp.security, "none")
          }

          env {
            name  = "MAILER_EMAIL_FROM"
            value = var.email.from_address
          }

          env {
            name  = "MAILER_NOREPLY_NAME"
            value = var.email.from_name
          }

          env {
            name  = "MAILER_NOREPLY_EMAIL"
            value = coalesce(var.email.reply_to, var.email.from_address)
          }

          port {
            container_port = 22300
          }

          readiness_probe {
            http_get {
              path = "/api/ping"
              port = 22300
              http_header {
                name  = "Host"
                value = var.domain
              }
            }
            initial_delay_seconds = 15
            period_seconds        = 10
          }

          liveness_probe {
            http_get {
              path = "/api/ping"
              port = 22300
              http_header {
                name  = "Host"
                value = var.domain
              }
            }
            initial_delay_seconds = 60
            period_seconds        = 30
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "joplin_app" {
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
      target_port = 22300
    }
  }
}

resource "kubernetes_ingress_v1" "joplin_app" {
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
              name = kubernetes_service_v1.joplin_app.metadata[0].name
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
