locals {
  namespace = "metallb-system"
}

resource "kubernetes_namespace" "metallb-namespace" {
  metadata {
    name = local.namespace
  }
}

resource "helm_release" "metallb" {
  name       = "metallb"
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
  namespace  = local.namespace
  wait       = true
}

resource "kubernetes_manifest" "metallb-ipaddress" {
  depends_on = [
    helm_release.metallb
  ]

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
  depends_on = [
    helm_release.metallb
  ]
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

resource "random_id" "memberlist" {
  byte_length = 128
}

resource "kubernetes_secret" "memberlist" {
  depends_on = [
    kubernetes_namespace.metallb-namespace
  ]
  metadata {
    name      = "memberlist"
    namespace = local.namespace
  }
  type = "generic"
  data = {
    "secretkey" = random_id.memberlist.b64_url
  }
}


