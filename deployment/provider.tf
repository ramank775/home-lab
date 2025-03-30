terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.25.0"
    }
    minio = {
      source  = "aminueza/minio"
      version = "3.3.0"
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

provider "postgresql" {
  host     = var.shared_db.proxy_host
  port     = var.shared_db.port
  database = var.shared_db.default_dbName
  username = var.shared_db.user
  password = var.shared_db.passwd
  sslmode  = var.shared_db.sslmode
}

provider "minio" {
  minio_server   = var.minio.proxy_server
  minio_user     = var.minio.user
  minio_password = var.minio.pass
}

data "terraform_remote_state" "deployment" {
  backend = "kubernetes"
  config = {
    secret_suffix    = "deployment-state"
    load_config_file = true
    config_path      = var.kube_config
  }
}
