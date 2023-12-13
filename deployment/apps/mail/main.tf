locals {
  prefix       = "mail-"
  dovecotName  = "${local.prefix}dovecot"
  data_volume  = "mail-directory"
  replicas     = 1
  devcotImage  = "ramank775/dovecot:${var.tag}"
  tunnelImage  = "ramank775/tunnel-client:${var.tunnel_client_tag}"
  tunnelName   = "${local.prefix}tunnel"
  spampdImage  = "ramank775/spampd:${var.spampd_tag}"
  spampdName   = "${local.prefix}spampd"
  spampdVolume = "spampd-dir"
  postfixadmin = "postfix-admin"
  bind9Name    = "${local.prefix}bind9"
}

resource "kubernetes_persistent_volume_claim" "mail_data_pv" {
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
        "storage" = "100Gi"
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
  depends_on = [
    kubernetes_persistent_volume_claim.mail_data_pv,
    kubernetes_config_map.dovecot_config
  ]
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

resource "kubernetes_deployment" "postfix-admin" {
  metadata {
    name      = local.postfixadmin
    namespace = var.namespace
    labels = {
      "app" = local.postfixadmin
    }
  }

  spec {
    replicas = local.replicas
    selector {
      match_labels = {
        "app" = local.postfixadmin
      }
    }
    template {
      metadata {
        labels = {
          app = local.postfixadmin
        }
      }

      spec {
        container {
          name              = local.postfixadmin
          image             = "postfixadmin:3.3.13"
          image_pull_policy = "Always"
          port {
            container_port = 80
          }
          env {
            name  = "POSTFIXADMIN_DB_TYPE"
            value = var.db_type
          }
          env {
            name  = "POSTFIXADMIN_DB_HOST"
            value = var.db_host
          }
          env {
            name  = "POSTFIXADMIN_DB_PORT"
            value = var.db_port
          }
          env {
            name  = "POSTFIXADMIN_DB_NAME"
            value = var.db_name
          }

          env {
            name  = "POSTFIXADMIN_DB_USER"
            value = var.db_user
          }
          env {
            name  = "POSTFIXADMIN_DB_PASSWORD"
            value = var.db_pass
          }
          env {
            name  = "POSTFIXADMIN_SMTP_SERVER"
            value = var.smtp_options.host
          }
          env {
            name  = "POSTFIXADMIN_SMTP_PORT"
            value = var.smtp_options.port
          }
          env {
            name  = "POSTFIXADMIN_SETUP_PASSWORD"
            value = var.postfix_admin_setup_password
          }
          env {
            name  = "POSTFIXADMIN_ENCRYPT"
            value = var.postfix_admin_encrypt
          }
          env {
            name = "POSTFIXADMIN_DKIM"
            value = "YES"
          }
          env {
            name = "POSTFIXADMIN_DKIM_ALL_ADMINS"
            value = "YES"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "postfixadmin_service" {
  metadata {
    namespace = var.namespace
    name      = "${local.postfixadmin}-service"
    labels = {
      "app" = local.postfixadmin
    }
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
      "app" = local.postfixadmin
    }
  }
}

resource "kubernetes_ingress_v1" "postfixadmin_ingress" {
  metadata {
    name      = "${local.postfixadmin}-ingress"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class"                      = "traefik"
      "traefik.ingress.kubernetes.io/router.middlewares" = "kube-system-redirect@kubernetescrd"
    }
  }
  spec {
    rule {
      host = "admin.${var.domain}"
      http {
        path {
          path = "/"
          backend {
            service {
              name = "${local.postfixadmin}-service"
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

resource "kubernetes_config_map" "bind9-config" {
  metadata {
    name      = "${local.bind9Name}-config"
    namespace = var.namespace
    labels = {
      app = local.bind9Name
    }
  }

  data = {
    "named.conf" = <<-EOF
options {
  directory "/var/cache/bind";

  recursion yes;
  allow-recursion { any; };
  
  dnssec-validation auto;

  auth-nxdomain no;    # conform to RFC1035
  allow-query     { any; };

  listen-on port 53 { any; };
  listen-on-v6 { any; };
  # forwarders {
  #   8.8.8.8;
  #   8.8.4.4;
  # };
};

plugin query "/usr/lib/aarch64-linux-gnu/bind/filter-aaaa.so" {
  filter-aaaa-on-v4 yes;
  filter-aaaa-on-v6 yes;
};
    EOF
  }
}

resource "kubernetes_deployment" "bind9-deployment" {
  metadata {
    name      = local.bind9Name
    namespace = var.namespace
    labels = {
      app = local.bind9Name
    }
  }

  spec {
    replicas = local.replicas

    selector {
      match_labels = {
        app = local.bind9Name
      }
    }

    template {
      metadata {
        labels = {
          app = local.bind9Name
        }
      }

      spec {
        container {
          name  = local.bind9Name
          image = "ubuntu/bind9:latest"

          port {
            container_port = 53
          }

          port {
            container_port = 53
            protocol       = "UDP"
          }

          volume_mount {
            name       = "bind9-config"
            mount_path = "/etc/bind/named.conf"
            sub_path   = "named.conf"
          }
        }
        volume {
          name = "bind9-config"
          config_map {
            name = "${local.bind9Name}-config"
            items {
              key  = "named.conf"
              path = "named.conf"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "bind9_service" {
  metadata {
    namespace = var.namespace
    name      = "${local.bind9Name}-service"
    labels = {
      app = local.bind9Name
    }
    annotations = {
      "metallb.universe.tf/ip-allocated-from-pool" = "homelab-ip"
    }
  }
  spec {
    type = "LoadBalancer"
    load_balancer_ip = var.mail_dns_server
    port {
      name        = "dns"
      port        = 53
      target_port = 53
      protocol    = "TCP"
    }

    port {
      name        = "dns-udp"
      port        = 53
      target_port = 53
      protocol    = "UDP"
    }


    selector = {
      "app" = local.bind9Name
    }
  }
}

# resource "kubernetes_persistent_volume_claim" "spampd-data" {
#   metadata {
#     name      = local.spampdVolume
#     namespace = var.namespace
#     labels = {
#       "app" = local.spampdVolume
#     }
#   }
#   wait_until_bound = false
#   spec {
#     resources {
#       requests = {
#         "storage" = "10Gi"
#       }
#     }
#     storage_class_name = "truenas-iscsi-csi"
#     access_modes       = ["ReadWriteOnce"]
#   }
# }

resource "kubernetes_config_map" "spampd_config" {
  depends_on = [
    kubernetes_service.bind9_service
  ]
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
    "dns.cf"            = <<EOT
dns_available yes
dns_server ${var.mail_dns_server}
dns_timeout 5
    EOT
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
          # volume_mount {
          #   mount_path = "/var/cache/spampd"
          #   name       = "spampd-data"
          # }
          volume_mount {
            name       = "spamassasin-config"
            mount_path = "/etc/spamassassin/miab_spf_dmarc.cf"
            sub_path   = "miab_spf_dmarc.cf"
          }
          volume_mount {
            name       = "spamassasin-cron-config"
            mount_path = "/etc/spamassassin/cron.cf"
            sub_path   = "cron.cf"
          }
          volume_mount {
            name       = "spamassasin-dns-config"
            mount_path = "/etc/spamassassin/dns.cf"
            sub_path   = "dns.cf"
          }
        }
        # volume {
        #   name = "spampd-data"
        #   persistent_volume_claim {
        #     claim_name = local.spampdVolume
        #   }
        # }
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
        volume {
          name = "spamassasin-dns-config"
          config_map {
            name = "${local.spampdName}-config"
            items {
              key  = "dns.cf"
              path = "dns.cf"
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
