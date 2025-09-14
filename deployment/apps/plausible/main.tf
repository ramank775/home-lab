
resource "random_password" "plausible_db_passwd" {
  length  = 16
  special = true
}

resource "postgresql_role" "plausible_db_user" {
  name     = "plausible"
  login    = true
  password = random_password.plausible_db_passwd.result
}

resource "postgresql_database" "plausible_db" {
  name                   = "plausible"
  owner                  = "plausible"
  template               = "template0"
  lc_collate             = "C"
  connection_limit       = -1
  allow_connections      = true
  alter_object_ownership = true
  depends_on             = [postgresql_role.plausible_db_user]
}


resource "random_password" "plausible_secret_key" {
  length  = 64
  special = true
}

resource "kubernetes_persistent_volume_claim" "plausible_data" {
  metadata {
    name      = "plausible-data"
    namespace = var.namespace
    labels = {
      "app" = "plausible"
    }
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    storage_class_name = "truenas-iscsi-csi"
  }
}

resource "kubernetes_secret" "plausible_google_oauth" {
  metadata {
    name      = "plausible-google-oauth"
    namespace = var.namespace
    labels = {
      "app" = "plausible"
    }
  }

  data = {
    client_id     = jsondecode(file(var.google_oauth_credentials_file_path))["web"]["client_id"]
    client_secret = jsondecode(file(var.google_oauth_credentials_file_path))["web"]["client_secret"]
  }

  type = "Opaque"
}

resource "kubernetes_deployment" "plausible" {
  metadata {
    name      = "plausible"
    namespace = var.namespace
    labels = {
      "app" = "plausible"
    }
  }

  spec {
    replicas = var.replicas
    selector {
      match_labels = {
        "app" = "plausible"
      }
    }
    template {
      metadata {
        labels = {
          "app" = "plausible"
        }
      }

      spec {
        init_container {
          name    = "fix-perms"
          image   = "busybox"
          command = ["sh", "-c"]
          args    = ["chmod ugo+rw -R /var/lib/plausible"]
          volume_mount {
            name       = "plausible-data"
            mount_path = "/var/lib/plausible"
          }
        }
        init_container {
          name              = "plausible-db-init"
          image             = "ghcr.io/plausible/community-edition:${var.plausible_version}"
          image_pull_policy = "IfNotPresent"
          command = [
            "sh",
            "-c",
          ]
          args = [
            "/entrypoint.sh db createdb && /entrypoint.sh db migrate"
          ]
          env {
            name  = "BASE_URL"
            value = var.base_url
          }
          env {
            name  = "DATABASE_URL"
            value = "postgresql://plausible:${random_password.plausible_db_passwd.result}@${var.postgresql.host}:${var.postgresql.port}/plausible"
          }
          env {
            name  = "CLICKHOUSE_DATABASE_URL"
            value = var.clickhouse.url
          }
          env {
            name  = "SECRET_KEY_BASE"
            value = random_password.plausible_secret_key.result
          }
          volume_mount {
            name       = "plausible-data"
            mount_path = "/var/lib/plausible"
          }
        }
        container {
          name              = "plausible"
          image             = "ghcr.io/plausible/community-edition:${var.plausible_version}"
          image_pull_policy = "IfNotPresent"

          env {
            name  = "BASE_URL"
            value = var.base_url
          }

          env {
            name  = "DATABASE_URL"
            value = "postgresql://plausible:${random_password.plausible_db_passwd.result}@${var.postgresql.host}:${var.postgresql.port}/plausible"
          }
          env {
            name  = "CLICKHOUSE_DATABASE_URL"
            value = var.clickhouse.url
          }
          env {
            name  = "SECRET_KEY_BASE"
            value = random_password.plausible_secret_key.result
          }

          env {
            name  = "TMPDIR"
            value = "/var/lib/plausible/tmp"
          }

          env {
            name  = "HTTP_PORT"
            value = "80"
          }

          env {
            name  = "SMTP_HOST_ADDR"
            value = var.smtp_options.host
          }

          env {
            name  = "SMTP_HOST_PORT"
            value = var.smtp_options.port
          }

          env {
            name  = "MAILER_EMAIL"
            value = var.mailer.email
          }

          env {
            name  = "MAILER_NAME"
            value = var.mailer.name
          }

          env {
            name = "DISABLE_REGISTRATION"
            value = "invite_only"
          }

          env {
            name = "ENABLE_EMAIL_VERIFICATION"
            value = "true"
          }


          env {
            name  = "GOOGLE_CLIENT_ID"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.plausible_google_oauth.metadata[0].name
                key  = "client_id"
              }
            }
          }

          env {
            name  = "GOOGLE_CLIENT_SECRET"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.plausible_google_oauth.metadata[0].name
                key  = "client_secret"
              }
            }
          }

          
          volume_mount {
            name       = "plausible-data"
            mount_path = "/var/lib/plausible"
          }

          port {
            container_port = 80
            protocol       = "TCP"
          }
        }

        volume {
          name = "plausible-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.plausible_data.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "plausible" {
  metadata {
    name      = "plausible"
    namespace = var.namespace
    labels = {
      "app" = "plausible"
    }
  }

  spec {
    selector = {
      "app" = "plausible"
    }
    type = "LoadBalancer"

    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }
  }
}
