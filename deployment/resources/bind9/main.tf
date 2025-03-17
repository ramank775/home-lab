locals {
  bind9Name = "bind9"
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

# plugin query "/usr/lib/aarch64-linux-gnu/bind/filter-aaaa.so" {
#   filter-aaaa-on-v4 yes;
#   filter-aaaa-on-v6 yes;
# };
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
    replicas = 1

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
  }
  spec {
    type             = "LoadBalancer"
    load_balancer_ip = var.external_ip
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
