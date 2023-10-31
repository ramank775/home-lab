locals {
  data_volume         = "vaultwarden-data"
  proxy_config_volume = "vw-proxy-config"
  app                 = "vaultwarden"
  replicas            = 1
}

resource "kubernetes_persistent_volume_claim" "vaultwarden_data" {
  metadata {
    name      = local.data_volume
    namespace = var.namespace
    labels = {
      "app" = local.data_volume
    }
  }
  wait_until_bound = false
  spec {
    resources {
      requests = {
        "storage" = "5Gi"
      }
    }
    storage_class_name = "truenas-iscsi-csi"
    access_modes       = ["ReadWriteOnce"]
  }
}

resource "kubernetes_config_map" "vw-proxy-config" {
  metadata {
    name      = local.proxy_config_volume
    namespace = var.namespace
    labels = {
      "app" = local.app
    }
  }

  data = {
    "default.conf" = <<EOT
    server {
        listen 80;
        server_name _;
        client_max_body_size 128M;
        
        location / {
          proxy_http_version 1.1;
          proxy_set_header "Connection" "";
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_pass http://localhost:8000;
        }

        location /notifications/hub/negotiate {
          proxy_http_version 1.1;
          proxy_set_header "Connection" "";

          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_pass http://localhost:8000;
        }

        location /notifications/hub {
          proxy_read_timeout 300s;
          proxy_connect_timeout 75s;
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";

          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header Forwarded $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_pass http://localhost:3012;
        }

    }
    EOT
  }
}

resource "kubernetes_deployment" "vaultwarden" {
  metadata {
    name      = local.app
    namespace = var.namespace
    labels = {
      "app" = local.app
    }
  }
  spec {
    replicas = local.replicas
    selector {
      match_labels = {
        "app" = local.app
      }
    }
    template {
      metadata {
        labels = {
          "app" = local.app
        }
      }
      spec {
        container {
          name              = local.app
          image_pull_policy = "Always"
          image             = "vaultwarden/server"
          env {
            name  = "WEBSOCKET_ENABLED"
            value = "true"
          }

          env {
            name  = "ROCKET_PORT"
            value = "8000"
          }

          env {
            name  = "SIGNUPS_ALLOWED"
            value = "false"
          }

          env {
            name  = "DOMAIN"
            value = var.public_domain
          }

          env {
            name  = "SMTP_HOST"
            value = var.smtp_options.host
          }
          env {
            name  = "SMTP_FROM"
            value = var.sender_mail
          }

          env {
            name  = "SMTP_SECURITY"
            value = lookup(var.smtp_options, "secruity", "off")
          }

          env {
            name  = "SMTP_PORT"
            value = var.smtp_options.port
          }

          volume_mount {
            mount_path = "/data"
            name       = "data"
          }
        }
        container {
          name              = "${local.app}-nginx"
          image_pull_policy = "Always"
          image             = "nginx:stable-alpine-slim"
          port {
            container_port = 80
          }
          volume_mount {
            name       = "confd"
            mount_path = "/etc/nginx/conf.d"
            read_only  = true
          }
        }
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = local.data_volume
          }
        }
        volume {
          name = "confd"
          config_map {
            name = local.proxy_config_volume
          }
        }
      }

    }
  }
}

resource "kubernetes_service" "vaultwarden_service" {
  metadata {
    name      = local.app
    namespace = var.namespace
    labels = {
      "app" = local.app
    }
  }
  spec {
    type = "ClusterIP"
    selector = {
      app = local.app
    }
    port {
      name        = "endpoint"
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_ingress_v1" "vaultwarden-ingress" {
  metadata {
    name      = "${local.app}-ingress"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class"                      = "traefik"
      "traefik.ingress.kubernetes.io/router.middlewares" = "kube-system-redirect@kubernetescrd"
    }
  }
  spec {
    rule {
      host = var.domain
      http {
        path {
          path = "/"
          backend {
            service {
              name = local.app
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
