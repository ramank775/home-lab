locals {
  image   = "${var.image}:${var.tag}"
  appname = "blog-feature-posts"
}

resource "kubernetes_cron_job" "blog-feature-posts_cron_job" {
  metadata {
    name      = local.appname
    namespace = var.namespace
    labels = {
      "app" = local.appname
    }
  }
  count = 1
  spec {
    schedule = "@midnight"
    job_template {
      metadata {
        labels = {
          "app" = local.appname
        }
      }
      spec {
        completions = 1
        template {
          metadata {
            labels = {
              "app" = local.appname
            }
          }
          spec {
            container {
              name              = local.appname
              image             = local.image
              image_pull_policy = "Always"
              env {
                name  = "GITHUB_TOKEN"
                value = var.github_token
              }
              env {
                name  = "ERROR_REPORTING_ENDPOINT"
                value = "${var.nats_streaming_http_producer_url}/publish/service-error"
              }
            }
            node_selector = var.node_selector
          }
        }
      }
    }
  }
}
