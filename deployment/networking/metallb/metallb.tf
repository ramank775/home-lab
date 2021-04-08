resource "kubernetes_config_map" "metallb-config" {
  metadata {
    name = "config"
    namespace = var.namespace
  }

  data = {
    "config" = <<EOF
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - ${var.iprange}
    EOF
  }
}