module "k3s" {
  source = "./k3s"
}

module "minio" {
  source = "./minio"
}

module "pve_storage" {
  source = "./pve_storage"
}

module "wp_serverless" {
  source      = "./wp_serverless"
  share_hosts = var.wp_serverless_share_hosts
}

module "mail" {
  source = "./mail"
}

module "nextcloud" {
  source = "./nextcloud"
}
