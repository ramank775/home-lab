terraform {
  required_version = ">= 0.13"
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    helm = {
      source = "hashicorp/helm"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
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

provider "kubectl" {
  config_path = var.kube_config
  host        = var.kube_host
  insecure    = var.kube_insecure
}
