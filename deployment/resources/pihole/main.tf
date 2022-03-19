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
        "storage" = "500Mi"
      }
    }
    storage_class_name = "longhorn"
    access_modes       = ["ReadWriteOnce"]
  }
}

# resource "kubernetes_config_map" "pihole-adlists" {
#   metadata {
#     namespace = var.namespace
#     name      = "pihole-adlists"
#     labels = {
#       "app" = local.appname
#     }
#   }
#   data = {
#     "adlists.list" = "https://dbl.oisd.nl https://raw.githubusercontent.com/kboghdady/youTube_ads_4_pi-hole/master/youtubelist.txt https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
#   }
# }

# resource "kubernetes_config_map" "pihole-regex" {
#   metadata {
#     namespace = var.namespace
#     name      = "pihole-regex"
#     labels = {
#       "app" = local.appname
#     }
#   }
#   data = {
#     "regex.list" = "^(.+[-_.])??adse?rv(er?|ice)?s?[0-9]*[-.]"
#   }
# }

resource "kubernetes_deployment" "pihole-deployment" {
  metadata {
    namespace = var.namespace
    name      = "pihole"
    labels = {
      "app" = local.appname
    }
  }
  spec {
    replicas = local.replica
    selector {
      match_labels = {
        "app" = local.appname
      }
    }
    strategy {
      type = "Recreate"
    }
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
          name  = local.appname
          image = local.image
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
        }
        volume {
          name = "pihole-config"
          persistent_volume_claim {
            claim_name = local.appname
            read_only  = false
          }
        }
        node_name = "pi-1"
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
