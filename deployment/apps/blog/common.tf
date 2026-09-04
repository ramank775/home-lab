locals {
  github_config = "github-config-secret"
  replicas      = 1
}

resource "kubernetes_secret_v1" "github_config" {
  metadata {
    name      = local.github_config
    namespace = var.namespace
  }
  data = var.github_config
}
