locals {
  data_volume   = "static-site-data"
  config_volume = "static-site-config"
  replicas      = 1
  static_server = "static-server"
  sftp_server   = "sftp-server"
}

resource "kubernetes_persistent_volume_claim" "static_site_data" {
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
        "storage" = "1Gi"
      }
    }
    storage_class_name = "truenas-iscsi-csi"
    access_modes       = ["ReadWriteOnce"]
  }
}

resource "kubernetes_persistent_volume_claim" "server_configuration" {
  metadata {
    name      = local.config_volume
    namespace = var.namespace
    labels = {
      "app" = local.config_volume
    }
  }
  wait_until_bound = false
  spec {
    resources {
      requests = {
        "storage" = "100Mi"
      }
    }
    storage_class_name = "truenas-iscsi-csi"
    access_modes       = ["ReadWriteOnce"]
  }
}

resource "kubernetes_deployment" "static_server" {
  metadata {
    name      = local.static_server
    namespace = var.namespace
    labels = {
      "app" = local.static_server
    }
  }

  spec {
    replicas = local.replicas
    selector {
      match_labels = {
        "app" = local.static_server
      }
    }
    template {
      metadata {
        labels = {
          "app" = local.static_server
        }
      }
      spec {
        container {
          name              = local.static_server
          image_pull_policy = "Always"
          image             = "ramank775/nginx-sftp:latest"
          env {
            name  = "USER"
            value = var.username
          }
          env {
            name  = "PASSWORD"
            value = var.password
          }

          port {
            container_port = 80
          }

          port {
            container_port = 22
          }
          volume_mount {
            mount_path = "/data"
            name       = "data"
          }

          volume_mount {
            mount_path = "/etc/ssh/keys/"
            name       = "config"
          }
        }

        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = local.data_volume
          }
        }

        volume {
          name = "config"
          persistent_volume_claim {
            claim_name = local.config_volume
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "static_server_service" {
  metadata {
    name      = local.static_server
    namespace = var.namespace
    labels = {
      "app" = local.static_server
    }
  }

  spec {
    type = "ClusterIP"
    selector = {
      "app" = local.static_server
    }
    port {
      name        = "endpoint"
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_service" "static_server_sftp" {
  metadata {
    name = local.sftp_server
    labels = {
      "app" = local.sftp_server
    }
    namespace = var.namespace
  }

  spec {
    type = "LoadBalancer"
    port {
      name        = "sftp"
      port        = 2222
      target_port = 22
    }
    port {
      name        = "http"
      port        = 80
      target_port = 80
    }
    selector = {
      "app" = local.static_server
    }
  }
}
