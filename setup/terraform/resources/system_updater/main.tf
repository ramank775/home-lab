terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

data "http" "system_updater_yaml" {
  method = "GET"
  url = "https://github.com/rancher/system-upgrade-controller/releases/latest/download/system-upgrade-controller.yaml"
}

resource "kubectl_manifest" "system-updater" {
  wait      = true
  yaml_body = file("${path.module}/manifest.yaml")
}

resource "kubectl_manifest" "system-upgrade-plan" {
  depends_on = [ kubectl_manifest.system-updater ]
  wait      = true
  yaml_body = file("${path.module}/plan.yaml")
}
