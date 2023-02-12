locals {
  image   = "${var.image}:${var.tag}"
  appname = "pihole"
  replica = var.replicas
}

resource "kubernetes_persistent_volume_claim" "pihole_pvc" {
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
        "storage" = "5Gi"
      }
    }
    storage_class_name = "truenas-iscsi-csi"
    access_modes       = ["ReadWriteOnce"]
  }
}

resource "kubernetes_config_map" "pihole-config" {
  metadata {
    namespace = var.namespace
    name      = "pihole-config"
    labels = {
      "app" = local.appname
    }
  }
  data = {
    "adlists.list" = file("${var.pihole_config_dir}/adlists.list")
    "custom.list"  = file("${var.pihole_config_dir}/custom.list")
  }
}

resource "kubernetes_stateful_set_v1" "name" {
  metadata {
    namespace = var.namespace
    name      = "pihole"
    labels = {
      "app" = local.appname
    }
  }
  spec {
    replicas               = local.replica
    revision_history_limit = 1
    selector {
      match_labels = {
        "app" = local.appname
      }
    }
    service_name = "${local.appname}-portal-service"

    template {
      metadata {
        annotations = {
        }

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
            name  = "TZ"
            value = var.tz
          }
          env {
            name  = "WEBPASSWORD"
            value = var.admin_pass
          }
          env {
            name  = "PIHOLE_DNS_"
            value = var.upstream_dns
          }
          volume_mount {
            name       = "pihole-config"
            mount_path = "/etc/pihole"
          }
          volume_mount {
            name       = "pihole-adlist-config"
            mount_path = "/etc/pihole/adlists.list"
            sub_path   = "adlists.list"
          }
          volume_mount {
            name       = "pihole-dns-config"
            mount_path = "/etc/pihole/custom.list"
            sub_path   = "custom.list"
          }
        }
        volume {
          name = "pihole-config"
          persistent_volume_claim {
            claim_name = local.appname
            read_only  = false
          }
        }
        volume {
          name = "pihole-adlist-config"
          config_map {
            default_mode = "0777"
            name         = "pihole-config"
            items {
              key  = "adlists.list"
              path = "adlists.list"
            }
          }
        }
        volume {
          name = "pihole-dns-config"
          config_map {
            default_mode = "0777"
            name         = "pihole-config"
            items {
              key  = "custom.list"
              path = "custom.list"
            }
          }
        }
        # node_selector = {
        #   "kubernetes.io/hostname" = "pi-1",
        # }
      }
    }
  }
}

resource "kubernetes_service" "pihole-portal-service" {
  metadata {
    name = "${local.appname}-portal-service"
    labels = {
      "app" = local.appname
    }
    namespace = var.namespace
  }

  spec {
    type = "ClusterIP"
    port {
      name        = "portal"
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }
    selector = {
      "app" = local.appname
    }
  }
}

resource "kubernetes_service" "pihole-dns-service" {
  metadata {
    name = "${local.appname}-dns-service"
    labels = {
      "app" = local.appname
    }
    namespace = var.namespace
  }

  spec {
    type = "LoadBalancer"
    port {
      name        = "dns"
      port        = 53
      target_port = 53
      protocol    = "UDP"
    }
    selector = {
      "app" = local.appname
    }
  }
}

resource "kubernetes_service" "pihole-admin-service" {
  metadata {
    name = "${local.appname}-admin-service"
    labels = {
      "app" = local.appname
    }
    namespace = var.namespace
  }

  spec {
    type = "LoadBalancer"
    port {
      name        = "admin"
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }
    selector = {
      "app" = local.appname
    }
  }
}

resource "kubernetes_ingress_v1" "pihole-ingress" {
  metadata {
    name      = local.appname
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class" = "traefik"
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
              name = "${local.appname}-portal-service"
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
