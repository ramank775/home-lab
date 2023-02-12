locals {
  namespace = "metallb-system"
}

resource "kubernetes_manifest" "metallb-ipaddress" {
  manifest = {
    apiVersion = "metallb.io/v1beta1"
    kind       = "IPAddressPool"
    metadata = {
      name      = "homelab-ip"
      namespace = local.namespace
    }
    spec = {
      addresses = [
        var.iprange
      ]
    }
  }

}

resource "kubernetes_manifest" "metallb-advertisement" {
  manifest = {
    "apiVersion" = "metallb.io/v1beta1"
    "kind"       = "L2Advertisement"
    "metadata" = {
      "name"      = "homelab-ip-advertisement"
      "namespace" = local.namespace
    }
    "spec" = {
      "ipAddressPools" = [
        "homelab-ip"
      ]
    }
  }
}
