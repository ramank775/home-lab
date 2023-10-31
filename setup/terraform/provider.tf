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
  backend "kubernetes" {
    secret_suffix = "setup-state"
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

data "terraform_remote_state" "setup" {
  backend = "kubernetes"
  config = {
    secret_suffix    = "setup-state"
    load_config_file = true
    config_path      = var.kube_config
    host             = var.kube_host
  }
}
