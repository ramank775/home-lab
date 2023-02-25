locals {
  image   = "${var.image}:${var.tag}"
  appname = "public-ip-monitor"
}

resource "kubernetes_persistent_volume_claim" "public_ip_monitor_pvc" {
  metadata {
    name      = local.appname
    namespace = var.namespace
    labels = {
      "app" = local.appname
    }
  }
  wait_until_bound = false
  spec {
    resources {
      requests = {
        "storage" = "1Mi"
      }
    }
    storage_class_name = "truenas-iscsi-csi"
    access_modes       = ["ReadWriteOnce"]
  }
}


resource "kubernetes_cron_job" "public_ip_monitor_cron_job" {
  metadata {
    name      = local.appname
    namespace = var.namespace
    labels = {
      "app" = local.appname
    }
  }
  count = var.replicas
  spec {
    schedule = "@hourly"
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
                name  = "UPDATE_ENDPOINT"
                value = "${var.nats_streaming_http_producer_url}/publish/public-ip-update"
              }
              volume_mount {
                name       = "data"
                mount_path = "/data"
                sub_path   = "data"
              }
            }
            volume {
              name = "data"
              persistent_volume_claim {
                claim_name = local.appname
              }
            }
            node_selector = var.node_selector
          }
        }
      }
    }
  }
}
