locals {
  image   = "${var.image}:${var.tag}"
  appname = "nats"
  replica = var.replicas
}

resource "kubernetes_deployment" "nats-deployment" {
  metadata {
    name = local.appname
    labels = {
      "app" = local.appname
    }
    namespace = var.namespace
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
          name = local.appname
          resources {
            requests = {
              "memory" = var.memorylimit
            }
          }
          image             = local.image
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 4222
            protocol       = "TCP"
          }
          command = ["/nats-streaming-server"]
          args = [
            "--store", "file",
            "--dir", "/data",
            "--cluster_id", var.clusterid,
            "-m", "8222"
          ]
          volume_mount {
            mount_path = "/data"
            name       = "data"
            sub_path   = "data"
          }
        }
        node_selector = var.node_selector
        volume {
          name = "data"
          empty_dir {

          }
        }

      }
    }

  }
}

resource "kubernetes_service" "nats-service" {
  metadata {
    name = local.appname
    labels = {
      "app" = local.appname
    }
    namespace = var.namespace
  }

  spec {
    type = "ClusterIP"
    port {
      name     = "clients"
      port     = 4222
      protocol = "TCP"
    }
    port {
      name     = "monitoring"
      port     = 8222
      protocol = "TCP"
    }
    selector = {
      "app" = local.appname
    }
  }
}
