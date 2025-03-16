locals {
  prefix      = "mail"
  dovecotName = "${local.prefix}-dovecot"
  data_volume = "mail-directory"
  replicas    = 1
  devcotImage = "ramank775/dovecot:${var.dovecot-tag}"
  spampdImage = "ramank775/spampd:${var.spampd_tag}"
  spampdName  = "${local.prefix}-spampd"


}

resource "kubernetes_namespace" "mail" {
  metadata {
    name = var.namespace
  }
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
  depends_on = [kubernetes_namespace.mail]
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

          env {
            name  = "SPAMC_HOST"
            value = "spamassassin-service"
          }

          volume_mount {
            name       = "dovecot-data"
            mount_path = "/srv/mail"
          }

          volume_mount {
            name       = "sieve-global"
            mount_path = "/srv/mail/sieve/default.sieve"
            sub_path   = "default.sieve"
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
          }
        }
        volume {
          name = "sieve-global"
          config_map {
            name = "${local.dovecotName}-config"
            items {
              key  = "default.sieve"
              path = "default.sieve"
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

resource "kubernetes_service" "dovecot_external_service" {
   metadata {
    namespace = var.namespace
    name      = "${local.dovecotName}-external"
    labels = {
      "app" = local.dovecotName
    }
  }
  spec {
    type = "LoadBalancer"
    port {
      name        = "imap"
      port        = 143
      target_port = 143
      protocol    = "TCP"
    }
    selector = {
      "app" = local.dovecotName
    }
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
    "dns.cf"            = <<EOT
dns_available yes
dns_server ${var.mail_dns_server}
# dns_timeout 5
    EOT

    "bayes.cf" = <<EOT
use_bayes 1
bayes_auto_learn 1

bayes_store_module  Mail::SpamAssassin::BayesStore::Redis
bayes_sql_dsn       server=${local.prefix}-redis-service:6379;database=0
bayes_token_ttl 21d
bayes_seen_ttl   8d
bayes_auto_expire 1
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
          env {
            name = "DEBUG"
            value = "true"
          }
          env {
            name = "SPAMPD_SA_MODE"
            value = "remote"
          }
          env {
            name = "SPAMPD_SACLIENT_HOST"
            value = "spamassassin-service"
          }
          env {
            name = "SPAMPD_SACLIENT_PORT"
            value = "783"
          }

          volume_mount {
            name       = "spamassasin-config"
            mount_path = "/etc/spamassassin/miab_spf_dmarc.cf"
            sub_path   = "miab_spf_dmarc.cf"
          }
          volume_mount {
            name       = "spamassasin-dns-config"
            mount_path = "/etc/spamassassin/dns.cf"
            sub_path   = "dns.cf"
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

resource "kubernetes_service" "spampd_external_service" {
  metadata {
    namespace = var.namespace
    name      = "${local.spampdName}-external"
    labels = {
      app = local.spampdName
    }
  }
  spec {
    type = "LoadBalancer"
    port {
      name        = "lmtp"
      port        = 24
      target_port = 24
      protocol    = "TCP"
    }

    selector = {
      app = local.spampdName
    }
  }

}


resource "kubernetes_service" "redis-service" {
  metadata {
    name      = "${local.prefix}-redis-service"
    namespace = var.namespace
    labels = {
      app = "${local.prefix}-redis-service"
    }
  }
  spec {
    type = "ClusterIP"
    port {
      name        = "redis"
      port        = 6379
      target_port = 6379
    }
    selector = {
      app = "${local.prefix}-redis"
    }
  }
}

resource "kubernetes_persistent_volume_claim" "redis_data_volume" {
  metadata {
    name      = "${local.prefix}-redis-data"
    namespace = var.namespace
    labels = {
      "app" = "${local.prefix}-redis-data"
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

resource "kubernetes_stateful_set_v1" "redis" {
  metadata {
    name      = "${local.prefix}-redis"
    namespace = var.namespace
    labels = {
      app = "${local.prefix}-redis"
    }
  }

  spec {
    replicas = local.replicas
    selector {
      match_labels = {
        app = "${local.prefix}-redis"
      }
    }
    service_name = "${local.prefix}-redis-service"
    template {
      metadata {
        labels = {
          app = "${local.prefix}-redis"
        }
      }
      spec {
        container {
          name              = "${local.prefix}-redis"
          image             = "redis:alpine"
          image_pull_policy = "Always"
          volume_mount {
            name       = "data"
            mount_path = "/data"
          }
        }
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = "${local.prefix}-redis-data"
          }
        }
      }
    }
  }
}

resource "kubernetes_stateful_set" "spamassassin" {
  metadata {
    namespace = var.namespace
    name      = "spamassassin"
    labels = {
      "app" = "spamassassin"
    }
  }

  spec {
    replicas               = local.replicas
    revision_history_limit = 1

    selector {
      match_labels = {
        app = "spamassassin"
      }
    }
    service_name = "spamassassin-service"
    template {
      metadata {
        labels = {
          app = "spamassassin"
        }
      }

      spec {
        container {
          name  = "spamassassin"
          image = "instantlinux/spamassassin:${var.spamassassin_tag}"
          env {
            name  = "TZ"
            value = "Asia/Kolkata"
          }
          env {
            name  = "EXTRA_OPTIONS"
            value = "--nouser-config"
          }
          port {
            container_port = 783
          }
          volume_mount {
            name       = "spamassasin-config"
            mount_path = "/etc/spamassassin/miab_spf_dmarc.cf"
            sub_path   = "miab_spf_dmarc.cf"
          }
          volume_mount {
            name       = "spamassasin-dns-config"
            mount_path = "/etc/spamassassin/dns.cf"
            sub_path   = "dns.cf"
          }
          volume_mount {
            name       = "spamassasin-bayes-config"
            mount_path = "/etc/spamassassin/bayes.cf"
            sub_path   = "bayes.cf"
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
          name = "spamassasin-dns-config"
          config_map {
            name = "${local.spampdName}-config"
            items {
              key  = "dns.cf"
              path = "dns.cf"
            }
          }
        }
        volume {
          name = "spamassasin-bayes-config"
          config_map {
            name = "${local.spampdName}-config"
            items {
              key  = "bayes.cf"
              path = "bayes.cf"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "spamassasin_service" {
  metadata {
    namespace = var.namespace
    name      = "spamassassin-service"
    labels = {
      "app" = "spamassassin"
    }
  }
  spec {
    type = "ClusterIP"
    port {
      port        = 783
      target_port = 783
      protocol    = "TCP"
    }

    selector = {
      "app" = "spamassassin"
    }
  }
}
