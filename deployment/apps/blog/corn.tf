locals {
  image    = "ramank775/blog_feature_post:v1.0.2"
  appname  = "blog-feature-posts"
}

resource "kubernetes_cron_job_v1" "blog-feature-posts_cron_job" {
  metadata {
    name      = local.appname
    namespace = var.namespace
    labels = {
      app = local.appname
    }
  }
  count = local.replicas
  spec {
    schedule = "@midnight"
    job_template {
      metadata {
        labels = {
          app = local.appname
        }
      }
      spec {
        completions = 1
        template {
          metadata {
            labels = {
              app = local.appname
            }
          }
          spec {
            container {
              name              = local.appname
              image             = local.image
              image_pull_policy = "IfNotPresent"
              env {
                name = "GITHUB_TOKEN"
                value_from {
                  secret_key_ref {
                    name = local.github_config
                    key  = "token"
                  }
                }
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
