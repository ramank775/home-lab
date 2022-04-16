locals {
  image    = "${var.image}:${var.tag}"
  appname  = "visitor-badge"
  replicas = var.replicas

}

resource "kubernetes_deployment" "visitor_badge_deployement" {
  metadata {
    name      = local.appname
    namespace = var.namespace
    labels = {
      "app" = local.appname
    }
  }

  spec {
    replicas = local.replicas
    selector {
      match_labels = {
        "app" = local.appname
      }
    }
    template {
      metadata {
        labels = {
          "app" = local.appname
        }
      }

      spec {
        container {
          name = local.appname
          resources {
            limits = {
              "memory" = var.memorylimit
            }
          }
          image             = local.image
          image_pull_policy = "IfNotPresent"

          env {
            name  = "md5_key"
            value = "guess_what"
          }

          port {
            container_port = 5000
            protocol       = "TCP"
          }

        }
        node_selector = var.node_selector
      }
    }

  }
}

resource "kubernetes_service" "visitor_badge_service" {
  metadata {
    name      = local.appname
    namespace = var.namespace
    labels = {
      "app" = local.appname
    }
  }

  spec {
    type = "ClusterIP"
    selector = {
      "app" = local.appname
    }
    port {
      name        = "endpoint"
      port        = 80
      target_port = 5000
      protocol    = "TCP"
    }
  }
}
