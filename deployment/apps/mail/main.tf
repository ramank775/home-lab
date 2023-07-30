locals {
  prefix       = "mail-"
  dovecotName  = "${local.prefix}dovecot"
  data_volume  = "mail-dir"
  replicas     = 1
  devcotImage  = "ramank775/dovecot:${var.tag}"
  tunnelImage  = "ramank775/tunnel-client:${var.tunnel_client_tag}"
  tunnelName   = "${local.prefix}tunnel"
  spampdImage  = "ramank775/spampd:${var.spampd_tag}"
  spampdName   = "${local.prefix}spampd"
  spampdVolume = "spampd-dir"
}

resource "kubernetes_persistent_volume_claim" "mail_data" {
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
        "storage" = "10Gi"
      }
    }
    storage_class_name = "truenas-iscsi-csi"
    access_modes       = ["ReadWriteOnce"]
  }
}

resource "kubernetes_config_map" "dovecot_config" {
  metadata {
    name      = "${local.dovecotName}-config"
    namespace = var.namespace
    labels = {
      "app" = local.dovecotName
    }
  }

  data = {
    "dovecot.conf"     = file("${var.dovecot_config_dir}/dovecot.conf")
    "dovecot-sql.conf" = file("${var.dovecot_config_dir}/dovecot-sql.conf")
    "default.sieve"    = file("${var.dovecot_config_dir}/default.sieve")
  }
}

resource "kubernetes_stateful_set_v1" "dovecot" {
  metadata {
    namespace = var.namespace
    name      = local.dovecotName
    labels = {
      "app" = local.dovecotName
    }
  }

  spec {
    replicas               = local.replicas
    revision_history_limit = 1

    selector {
      match_labels = {
        app = local.dovecotName
      }
    }
    service_name = "${local.dovecotName}-service"
    template {
      metadata {
        labels = {
          app = local.dovecotName
        }
      }

      spec {
        container {
          name  = local.dovecotName
          image = local.devcotImage
          port {
            container_port = 143
          }

          port {
            container_port = 24
          }

          volume_mount {
            name       = "dovecot-data"
            mount_path = "/srv/mail"
          }

          volume_mount {
            name       = "dovecot-config"
            mount_path = "/etc/dovecot/"
          }
        }

        volume {
          name = "dovecot-data"
          persistent_volume_claim {
            read_only  = false
            claim_name = local.data_volume
          }
        }
        volume {
          name = "dovecot-config"
          config_map {
            name = "${local.dovecotName}-config"
            items {
              key  = "dovecot.conf"
              path = "dovecot.conf"
            }
            items {
              key  = "dovecot-sql.conf"
              path = "dovecot-sql.conf"
            }
            items {
              key  = "default.sieve"
              path = "sieve/default.sieve"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "dovecot_service" {
  metadata {
    namespace = var.namespace
    name      = "${local.dovecotName}-service"
    labels = {
      "app" = local.dovecotName
    }
  }
  spec {
    type = "ClusterIP"
    port {
      name        = "imap"
      port        = 143
      target_port = 143
      protocol    = "TCP"
    }

    port {
      name        = "lmtp"
      port        = 24
      target_port = 24
      protocol    = "TCP"
    }

    selector = {
      "app" = local.dovecotName
    }
  }
}


resource "kubernetes_secret" "ssh_key_proxy_server" {
  metadata {
    name      = "mail-tunnel-ssh-key"
    namespace = var.namespace
    labels = {
      "app" = local.tunnelName
    }
  }

  data = {
    "id_rsa" = "${file(var.tunnel_ssh_key)}"
  }
  type = "Opaque"

}

resource "kubernetes_deployment" "tcp_tunnel_client_deployement" {
  metadata {
    name      = local.tunnelName
    namespace = var.namespace
    labels = {
      "app" = local.tunnelName
    }
  }

  spec {
    replicas = local.replicas
    selector {
      match_labels = {
        "app" = local.tunnelName
      }
    }
    template {
      metadata {
        labels = {
          "app" = local.tunnelName
        }
      }

      spec {
        container {
          name              = local.tunnelName
          image             = local.tunnelImage
          image_pull_policy = "IfNotPresent"
          env {
            name  = "PROXY_SSH_USER"
            value = var.tunnel_ssh_user
          }
          env {
            name  = "PROXY_HOST"
            value = var.tunnel_proxy_host
          }
          env {
            name  = "PROXY_SSH_PORT"
            value = var.tunnel_ssh_port
          }
          volume_mount {
            name       = "ssh-key"
            mount_path = "/config/.ssh/id_rsa"
            sub_path   = "id_rsa"
            read_only  = false
          }

          args = ["-R", "0.0.0.0:24:${local.spampdName}-service:24", "-R", "0.0.0.0:143:mail-dovecot-service:143", "-v"]
        }
        volume {
          name = "ssh-key"
          secret {
            default_mode = "0600"
            secret_name  = "mail-tunnel-ssh-key"
          }
        }

      }
    }

  }
}

resource "kubernetes_persistent_volume_claim" "spampd-data" {
  metadata {
    name      = local.spampdVolume
    namespace = var.namespace
    labels = {
      "app" = local.spampdVolume
    }
  }
  wait_until_bound = false
  spec {
    resources {
      requests = {
        "storage" = "10Gi"
      }
    }
    storage_class_name = "truenas-iscsi-csi"
    access_modes       = ["ReadWriteOnce"]
  }
}

resource "kubernetes_config_map" "spampd_config" {
  metadata {
    name      = "${local.spampdName}-config"
    namespace = var.namespace
    labels = {
      "app" = local.spampdName
    }
  }

  data = {
    "miab_spf_dmarc.cf" = file("${var.spampd_config_dir}/miab_spf_dmarc.cf")
    "cron.cf"           = file("${var.spampd_config_dir}/cron.cf")
  }
}

resource "kubernetes_deployment" "spampd" {
  metadata {
    namespace = var.namespace
    name      = local.spampdName
    labels = {
      "app" = local.spampdName
    }
  }

  spec {
    replicas = local.replicas
    selector {
      match_labels = {
        "app" = local.spampdName
      }
    }
    template {
      metadata {
        labels = {
          app = local.spampdName
        }
      }
      spec {
        container {
          name              = local.spampdName
          image             = local.spampdImage
          image_pull_policy = "IfNotPresent"
          env {
            name  = "SPAMPD_RELAYHOST"
            value = "mail-dovecot-service:24"
          }
          env {
            name  = "SPAMPD_HOST"
            value = "0.0.0.0:24"
          }
          volume_mount {
            mount_path = "/var/cache/spampd"
            name       = "spampd-data"
          }
          volume_mount {
            name       = "spamassasin-config"
            mount_path = "/etc/spamassassin/miab_spf_dmarc.cf"
          }
          volume_mount {
            name       = "spamassasin-cron-config"
            mount_path = "/etc/spamassassin/cron.cf"
          }
        }
        volume {
          name = "spampd-data"
          persistent_volume_claim {
            claim_name = local.spampdVolume
          }
        }
        volume {
          name = "spamassasin-config"
          config_map {
            name = "${local.spampdName}-config"
            items {
              key  = "miab_spf_dmarc.cf"
              path = "miab_spf_dmarc.cf"
            }
          }
        }
        volume {
          name = "spamassasin-cron-config"
          config_map {
            name = "${local.spampdName}-config"
            items {
              key  = "cron.cf"
              path = "cron.cf"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "spampd_service" {
  metadata {
    namespace = var.namespace
    name      = "${local.spampdName}-service"
    labels = {
      "app" = local.spampdName
    }
  }
  spec {
    type = "ClusterIP"
    port {
      name        = "lmtp"
      port        = 24
      target_port = 24
      protocol    = "TCP"
    }

    selector = {
      "app" = local.spampdName
    }
  }
}

resource "kubernetes_deployment" "tcp_tunnel_client_deployement" {
  metadata {
    name      = local.tunnelName
    namespace = var.namespace
    labels = {
      "app" = local.tunnelName
    }
  }

  spec {
    replicas = local.replicas
    selector {
      match_labels = {
        "app" = local.tunnelName
      }
    }
    template {
      metadata {
        labels = {
          "app" = local.tunnelName
        }
      }

      spec {
        container {
          name              = local.tunnelName
          image             = local.tunnelImage
          image_pull_policy = "IfNotPresent"
          env {
            name  = "PROXY_SSH_USER"
            value = var.tunnel_ssh_user
          }
          env {
            name  = "PROXY_HOST"
            value = var.tunnel_proxy_host
          }
          env {
            name  = "PROXY_SSH_PORT"
            value = var.tunnel_ssh_port
          }
          volume_mount {
            name       = "ssh-key"
            mount_path = "/config/.ssh/id_rsa"
            sub_path   = "id_rsa"
            read_only  = false
          }

          args = ["-R", "0.0.0.0:24:${local.spampdName}-service:24", "-R", "0.0.0.0:143:mail-dovecot-service:143", "-v"]
        }
        volume {
          name = "ssh-key"
          secret {
            default_mode = "0600"
            secret_name  = "mail-tunnel-ssh-key"
          }
        }

      }
    }

  }
}
