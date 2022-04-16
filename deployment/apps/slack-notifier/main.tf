locals {
  image    = "${var.image}:${var.tag}"
  appname  = "slack-notifier"
  replicas = var.replicas
}

resource "kubernetes_config_map" "slack_notifier_config_map" {
  metadata {
    name      = local.appname
    namespace = var.namespace
    labels = {
      "app" = local.appname
    }
  }

  data = {
    "preference.json" = <<EOT
    [
        {
            "subject": "public-ip-update",
            "endpoint": "${var.slack_endpoint}",
            "template": "Alert!! Public ip of home lab got updated from {old_ip} to {new_ip}"
        },
        {
            "subject": "service-error",
            "endpoint": "${var.slack_endpoint}",
            "template": "Alert!! {name} throws error {error}"
        }
    ]
    EOT
  }
}

resource "kubernetes_deployment" "slack_notifier_deployement" {
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
          image_pull_policy = "IfNotPresent"
          image             = local.image
          env {
            name  = "NATS_CLUSTER_ID"
            value = var.nats_cluster_id
          }
          env {
            name  = "NATS_URL"
            value = var.nats_url
          }
          env {
            name  = "NATS_CLIENT_ID"
            value = var.client_id
          }
          volume_mount {
            mount_path = "/app/preference.json"
            name       = "preference"
            sub_path   = "preference.json"
            read_only  = true
          }
        }

        volume {
          name = "preference"
          config_map {
            name = "slack-notifier"
            items {
              key  = "preference.json"
              path = "preference.json"
            }
          }
        }

        node_selector = var.node_selector
      }
    }
  }
}
