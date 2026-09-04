locals {
  appname = "temporal"
}

# --- Postgres role + databases on shared LXC ---------------------------------
# Temporal needs two DBs: one for persistence (DBNAME), one for visibility
# (VISIBILITY_DBNAME). auto-setup runs `temporal-sql-tool setup-schema` against
# both. We create the role/DBs here so SKIP_DB_CREATE=true on the server side.

resource "random_password" "db_passwd" {
  length           = 24
  special          = true
  override_special = "_-"
}

resource "postgresql_role" "db_user" {
  name     = local.appname
  login    = true
  password = random_password.db_passwd.result
}

resource "postgresql_database" "temporal" {
  name                   = local.appname
  owner                  = postgresql_role.db_user.name
  template               = "template0"
  lc_collate             = "C"
  connection_limit       = -1
  allow_connections      = true
  alter_object_ownership = true
  depends_on             = [postgresql_role.db_user]
}

resource "postgresql_database" "temporal_visibility" {
  name                   = "${local.appname}_visibility"
  owner                  = postgresql_role.db_user.name
  template               = "template0"
  lc_collate             = "C"
  connection_limit       = -1
  allow_connections      = true
  alter_object_ownership = true
  depends_on             = [postgresql_role.db_user]
}

# --- Elasticsearch (visibility backend) --------------------------------------
# Temporal v1.28 advanced visibility requires ES v7. Single-node, JVM capped
# at 256m matching upstream compose. amd64-only — JVM RAM headroom.

resource "kubernetes_service_v1" "elasticsearch" {
  metadata {
    name      = "${local.appname}-elasticsearch"
    namespace = var.namespace
    labels = {
      app = "${local.appname}-elasticsearch"
    }
  }
  spec {
    type = "ClusterIP"
    port {
      name        = "http"
      port        = 9200
      target_port = 9200
    }
    selector = {
      app = "${local.appname}-elasticsearch"
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "elasticsearch_data" {
  metadata {
    name      = "${local.appname}-elasticsearch-data"
    namespace = var.namespace
    labels = {
      app = "${local.appname}-elasticsearch"
    }
  }
  wait_until_bound = true
  spec {
    resources {
      requests = {
        storage = var.elasticsearch_storage_size
      }
    }
    storage_class_name = var.storage_class
    access_modes       = ["ReadWriteOnce"]
  }
}

resource "kubernetes_stateful_set_v1" "elasticsearch" {
  metadata {
    name      = "${local.appname}-elasticsearch"
    namespace = var.namespace
    labels = {
      app = "${local.appname}-elasticsearch"
    }
  }

  spec {
    replicas     = 1
    service_name = kubernetes_service_v1.elasticsearch.metadata[0].name
    selector {
      match_labels = {
        app = "${local.appname}-elasticsearch"
      }
    }
    template {
      metadata {
        labels = {
          app = "${local.appname}-elasticsearch"
        }
      }
      spec {
        node_selector = {
          "kubernetes.io/arch" = "amd64"
        }
        # ES 7.x image runs as uid 1000 but TrueNAS iSCSI PVs mount root-owned;
        # fsGroup chgrps the mount root but doesn't recurse into pre-existing
        # subdirs from failed prior boots, so we also chown -R in an initContainer.
        security_context {
          fs_group = 1000
        }
        init_container {
          name    = "chown-data"
          image   = "busybox:1.36"
          command = ["sh", "-c", "chown -R 1000:1000 /usr/share/elasticsearch/data"]
          security_context {
            run_as_user = 0
          }
          volume_mount {
            name       = "data"
            mount_path = "/usr/share/elasticsearch/data"
          }
        }
        container {
          name              = "elasticsearch"
          image             = "docker.elastic.co/elasticsearch/elasticsearch:${var.elasticsearch_image_tag}"
          image_pull_policy = "IfNotPresent"

          env {
            name  = "cluster.routing.allocation.disk.threshold_enabled"
            value = "true"
          }
          env {
            name  = "cluster.routing.allocation.disk.watermark.low"
            value = "512mb"
          }
          env {
            name  = "cluster.routing.allocation.disk.watermark.high"
            value = "256mb"
          }
          env {
            name  = "cluster.routing.allocation.disk.watermark.flood_stage"
            value = "128mb"
          }
          env {
            name  = "discovery.type"
            value = "single-node"
          }
          env {
            name  = "ES_JAVA_OPTS"
            value = "-Xms256m -Xmx256m"
          }
          env {
            name  = "xpack.security.enabled"
            value = "false"
          }

          port {
            name           = "http"
            container_port = 9200
          }

          resources {
            requests = {
              memory = "512Mi"
              cpu    = "100m"
            }
            limits = {
              memory = "1Gi"
            }
          }

          volume_mount {
            name       = "data"
            mount_path = "/usr/share/elasticsearch/data"
          }
        }

        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.elasticsearch_data.metadata[0].name
          }
        }
      }
    }
  }
}

# --- Temporal server (auto-setup) --------------------------------------------

resource "kubernetes_service_v1" "temporal_server" {
  metadata {
    name      = local.appname
    namespace = var.namespace
    labels = {
      app = local.appname
    }
  }
  spec {
    type = "ClusterIP"
    port {
      name        = "grpc"
      port        = 7233
      target_port = 7233
    }
    selector = {
      app = local.appname
    }
  }
}

resource "kubernetes_deployment_v1" "temporal_server" {
  metadata {
    name      = local.appname
    namespace = var.namespace
    labels = {
      app = local.appname
    }
  }

  spec {
    replicas = 1
    strategy {
      type = "Recreate"
    }
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
        node_selector = {
          "kubernetes.io/arch" = "amd64"
        }
        container {
          name              = "temporal"
          image             = "temporalio/auto-setup:${var.server_image_tag}"
          image_pull_policy = "IfNotPresent"

          env {
            name  = "DB"
            value = "postgres12"
          }
          env {
            name  = "DB_PORT"
            value = tostring(var.database.port)
          }
          env {
            name  = "POSTGRES_SEEDS"
            value = var.database.host
          }
          env {
            name  = "POSTGRES_USER"
            value = postgresql_role.db_user.name
          }
          env {
            name  = "POSTGRES_PWD"
            value = random_password.db_passwd.result
          }
          env {
            name  = "DBNAME"
            value = postgresql_database.temporal.name
          }
          env {
            name  = "VISIBILITY_DBNAME"
            value = postgresql_database.temporal_visibility.name
          }
          env {
            name  = "SKIP_DB_CREATE"
            value = "true"
          }

          env {
            name  = "ENABLE_ES"
            value = "true"
          }
          env {
            name  = "ES_SEEDS"
            value = kubernetes_service_v1.elasticsearch.metadata[0].name
          }
          env {
            name  = "ES_VERSION"
            value = "v7"
          }

          env {
            name  = "TEMPORAL_NAMESPACE"
            value = "default"
          }
          env {
            name  = "DEFAULT_NAMESPACE"
            value = "default"
          }
          env {
            name  = "DEFAULT_NAMESPACE_RETENTION"
            value = "24h"
          }

          port {
            name           = "grpc"
            container_port = 7233
          }

          resources {
            requests = {
              memory = "256Mi"
              cpu    = "100m"
            }
            limits = {
              memory = "512Mi"
            }
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_stateful_set_v1.elasticsearch,
    postgresql_database.temporal,
    postgresql_database.temporal_visibility,
  ]
}

# --- Temporal UI --------------------------------------------------------------

resource "kubernetes_service_v1" "temporal_ui" {
  metadata {
    name      = "${local.appname}-ui"
    namespace = var.namespace
    labels = {
      app = "${local.appname}-ui"
    }
  }
  spec {
    type = "ClusterIP"
    port {
      name        = "http"
      port        = 80
      target_port = 8080
    }
    selector = {
      app = "${local.appname}-ui"
    }
  }
}

resource "kubernetes_deployment_v1" "temporal_ui" {
  metadata {
    name      = "${local.appname}-ui"
    namespace = var.namespace
    labels = {
      app = "${local.appname}-ui"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "${local.appname}-ui"
      }
    }
    template {
      metadata {
        labels = {
          app = "${local.appname}-ui"
        }
      }
      spec {
        # Kubernetes auto-injects TEMPORAL_PORT=tcp://<ip>:7233 etc. for every
        # Service in this namespace, which the temporal-ui binary mistakes for
        # its own config keys (it expects TEMPORAL_PORT to be an int). Disable.
        enable_service_links = false

        container {
          name              = "temporal-ui"
          image             = "temporalio/ui:${var.ui_image_tag}"
          image_pull_policy = "IfNotPresent"

          env {
            name  = "TEMPORAL_ADDRESS"
            value = "${kubernetes_service_v1.temporal_server.metadata[0].name}:7233"
          }
          env {
            name  = "TEMPORAL_CORS_ORIGINS"
            value = "https://temporal.${var.domain}"
          }

          port {
            name           = "http"
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress_v1" "temporal_ui" {
  metadata {
    name      = "${local.appname}-ui"
    namespace = var.namespace
  }

  spec {
    rule {
      host = "temporal.${var.domain}"
      http {
        path {
          path = "/"
          backend {
            service {
              name = kubernetes_service_v1.temporal_ui.metadata[0].name
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
