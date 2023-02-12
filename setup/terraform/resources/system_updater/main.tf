terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

data "http" "system_updater_yaml" {
  url = "https://github.com/rancher/system-upgrade-controller/releases/latest/download/system-upgrade-controller.yaml"
}

resource "kubectl_manifest" "system-updater" {
  wait      = true
  yaml_body = data.http.system_updater_yaml.response_body
}
