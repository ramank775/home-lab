terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
  backend "kubernetes" {
    secret_suffix = "deployment-state"
  }
}

provider "kubernetes" {
  config_path = var.kube_config
  host        = var.kube_host
  insecure    = var.kube_insecure
}

provider "helm" {
  kubernetes {
    config_path = var.kube_config
    host        = var.kube_host
    insecure    = var.kube_insecure
  }
}

data "terraform_remote_state" "deployment" {
  backend = "kubernetes"
  config = {
    secret_suffix    = "deployment-state"
    load_config_file = true
    config_path      = var.kube_config
  }
}
