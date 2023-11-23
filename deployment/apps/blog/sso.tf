locals {
  appName = "blog-sso"
}

resource "kubernetes_deployment" "blog_sso" {
  metadata {
    name      = local.appName
    namespace = var.namespace
    labels = {
      app = local.appName
    }
  }

  spec {
    replicas = local.replicas
    selector {
      match_labels = {
        app = local.appName
      }
    }
    template {
      metadata {
        labels = {
          app = local.appName
        }
      }
      spec {
        container {
          name              = local.appName
          image_pull_policy = "Always"
          image             = "ramank775/netlify-cms-github-oauth-provider:latest"

          env {
            name  = "NODE_ENV"
            value = "production"
          }

          env {
            name  = "PORT"
            value = 80
          }

          env {
            name  = "ORIGINS"
            value = var.domain
          }

          env {
            name  = "REDIRECT_URL"
            value = "https://sso-${var.domain}/callback"
          }

          env {
            name = "OAUTH_CLIENT_ID"
            value_from {
              secret_key_ref {
                name = local.github_config
                key  = "client_id"
              }
            }
          }

          env {
            name = "OAUTH_CLIENT_SECRET"
            value_from {
              secret_key_ref {
                name = local.github_config
                key  = "client_secret"
              }
            }
          }

          port {
            container_port = 80
          }

        }
      }
    }
  }
}

resource "kubernetes_service" "blog_sso_service" {
  metadata {
    name      = "sso-blog"
    namespace = var.namespace
    labels = {
      app = local.appName
    }
  }
  spec {
    type = "ClusterIP"
    port {
      name        = "http"
      port        = 80
      target_port = 80
    }

    selector = {
      app = local.appName
    }
  }
}
