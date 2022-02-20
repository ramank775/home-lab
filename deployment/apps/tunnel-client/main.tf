locals {
  image    = "${var.image}:${var.tag}"
  appname  = "tcp-tunnel-client"
  replicas = var.replicas

}

resource "kubernetes_secret" "ssh_key_proxy_server" {
  metadata {
    name      = "tunnel-ssh-key"
    namespace = var.namespace
    labels = {
      "app" = local.appname
    }
  }

  data = {
    "id_rsa" = "${file(var.tunnel_ssh_key)}"
  }
  type = "Opaque"

}

resource "kubernetes_config_map" "tunnel_nginx_config_map" {
  metadata {
    name      = "tunnel-nginx-config-map"
    namespace = var.namespace
    labels = {
      "app" = local.appname
    }
  }

  data = {
    "default.conf" = <<EOT
        location / {
            default_type text/html;
            return 200 "Hello from custom file";
        }
    EOT
  }
}

resource "kubernetes_deployment" "tcp_tunnel_client_deployement" {
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
          image_pull_policy = "Always"
          env {
            name  = "PROXY_SSH_USER"
            value = var.tunnel_ssh_user
          }
          env {
            name  = "PROXY_HOST"
            value = var.tunnel_proxy_host
          }
          env {
            name  = "REMOTE_PORT"
            value = var.tunnel_remote_port
          }
          env {
            name  = "PROXY_SSH_PORT"
            value = var.tunnel_ssh_port
          }
          port {
            container_port = 80
            protocol       = "TCP"
          }
          readiness_probe {
            http_get {
              path = "/health"
              port = 80
            }
            timeout_seconds = 30
          }
          liveness_probe {
            http_get {
              path = "/health"
              port = 80
            }
            timeout_seconds = 30
          }
          volume_mount {
            name       = "ssh-key"
            mount_path = "/config/.ssh/id_rsa"
            sub_path   = "id_rsa"
            read_only  = false
          }
          volume_mount {
            name       = "default-conf"
            mount_path = "/config/nginx/default.d"
            read_only  = true
          }
        }
        volume {
          name = "ssh-key"
          secret {
            default_mode = "0600"
            secret_name  = "tunnel-ssh-key"
          }
        }
        volume {
          name = "default-conf"
          config_map {
            name = "tunnel-nginx-config-map"
          }
        }
      }
    }

  }
}
