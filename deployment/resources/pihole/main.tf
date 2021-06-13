locals {
  image   = "${var.image}:${var.tag}"
  appname = "pihole"
  replica = var.replicas
}

resource "kubernetes_config_map" "pihole-adlists" {
  metadata {
    namespace = var.namespace
    name      = "pihole-adlists"
    labels = {
      "app" = local.appname
    }
  }
  data = {
    "adlists.list" = <<EOF
    https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
    EOF
  }
}

resource "kubernetes_config_map" "pihole-regex" {
  metadata {
    namespace = var.namespace
    name      = "pihole-regex"
    labels = {
      "app" = local.appname
    }
  }
  data = {
    "regex.list" = <<EOF
    ^(.+[-_.])??adse?rv(er?|ice)?s?[0-9]*[-.]
    EOF
  }
}

resource "kubernetes_config_map" "pihole-env" {
  metadata {
    namespace = var.namespace
    name      = "pihole-env"
    labels = {
      "app" = local.appname
    }
  }
  data = {
    "TZ" : "ASIA/KOLKATA",
    "DNS1" : "1.1.1.1",
    "DNS2" : "1.0.0.1"
  }
}

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
            name = "TZ"
            value_from {
              config_map_key_ref {
                name = "pihole-env"
                key  = "TZ"
              }
            }
          }
          volume_mount {
            name       = "pihole-adlists"
            mount_path = "/etc/pihole/adlists.list"
            sub_path   = "adlists.list"
          }
          volume_mount {
            name       = "pihole-regex"
            mount_path = "/etc/pihole/regex.list"
            sub_path   = "regex.list"
          }
        }
        volume {
          name = "pihole-adlists"
          config_map {
            name = "pihole-adlists"
          }
        }
        volume {
          name = "pihole-regex"
          config_map {
            name = "pihole-regex"
          }
        }
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
