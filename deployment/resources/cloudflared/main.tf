locals {
  image    = "${var.image}:${var.tag}"
  appname  = "cloudflared"
  replicas = var.replicas

}

resource "kubernetes_secret" "cloudflared_tunnel_cred" {
  metadata {
    name      = "cloudflared-tunnel-cred"
    namespace = var.namespace
    labels = {
      "app" = local.appname
    }
  }

  data = {
    "credentials.json" = file(var.cloudflared_cred_file),
    "cert.pem"         = file(var.cloudflared_cert_file),
  }
  type = "Opaque"

}

resource "kubernetes_config_map" "cloudflared_tunnel_config" {
  metadata {
    name      = "cloudflared-tunnel-config"
    namespace = var.namespace
    labels = {
      "app" = local.appname
    }
  }

  data = {
    "config.yaml" = file(var.cloudflared_config_file)
  }
}

resource "kubernetes_deployment" "cloudflared_tunnel_deployement" {
  depends_on = [
    kubernetes_config_map.cloudflared_tunnel_config,
    kubernetes_secret.cloudflared_tunnel_cred
  ]
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

          args = [
            "tunnel",
            "--config",
            "/etc/cloudflared/config/config.yaml",
            "run"
          ]

          liveness_probe {
            http_get {
              path = "/ready"
              port = 2000
            }
            failure_threshold     = 1
            initial_delay_seconds = 10
            timeout_seconds       = 30
          }
          volume_mount {
            name       = "config"
            mount_path = "/etc/cloudflared/config"
            read_only  = true
          }
          volume_mount {
            name       = "creds"
            mount_path = "/etc/cloudflared/creds"
            read_only  = true
          }
        }
        volume {
          name = "creds"
          secret {
            secret_name = "cloudflared-tunnel-cred"
          }
        }
        volume {
          name = "config"
          config_map {
            name = "cloudflared-tunnel-config"
            items {
              key  = "config.yaml"
              path = "config.yaml"
            }
          }
        }
        node_selector = var.node_selector
      }
    }

  }
}
