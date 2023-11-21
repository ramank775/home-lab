locals {
  image   = "${var.image}:${var.tag}"
  appname = "smtp-relay"
}

resource "kubernetes_deployment" "smtp-relay" {
  metadata {
    name = local.appname
    namespace = var.namespace
    labels = {
      app = local.appname
    }
  }
  spec {
    replicas = var.replicas
    selector {
      match_labels = {
        app = local.appname
      }
    }
    template {
      metadata {
        labels = {
          app = local.appname
        }
      }
      spec {
        container {
          name = local.appname
          image = local.image
          image_pull_policy = "IfNotPresent"
          env {
            name = "SMTP_RELAY_HOST"
            value = var.smtp_relay_host
          }
          env {
            name = "SMTP_RELAY_MYHOSTNAME"
            value = "smtp-relay.${var.domain}"
          }
          env {
            name = "SMTP_RELAY_USERNAME"
            value = var.smtp_relay_user
          }
          env {
            name = "SMTP_RELAY_PASSWORD"
            value = var.smtp_relay_pass
          }
          env {
            name = "SMTP_RELAY_MYNETWORKS"
            value = var.smtp_relay_networks
          }
          env {
            name = "SMTP_RELAY_WRAPPERMODE"
            value = "no"
          }
          env {
            name = "SMTP_TLS_SECURITY_LEVEL"
            value = "encrypt"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "smtp-service" {
  metadata {
    name = local.appname
    labels = {
      app = local.appname
    }
    namespace = var.namespace
  }

  spec {
    type = "ClusterIP"
    port {
      name     = "smtp"
      port     = 25
      protocol = "TCP"
    }
    selector = {
      app = local.appname
    }
  }
}

resource "kubernetes_service" "smtp-internal-service" {
  metadata {
    name = "${local.appname}-internal-service"
    labels = {
      "app" = local.appname
    }
    annotations = {
      "metallb.universe.tf/ip-allocated-from-pool" = "homelab-ip"
    }
    namespace = var.namespace
  }

  spec {
    type = "LoadBalancer"
    port {
      name        = "smtp"
      port        = 25
      target_port = 25
    }
    selector = {
      "app" = local.appname
    }
  }
}