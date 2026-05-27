module "k3s" {
  source    = "./k3s"
  node_name = var.pve_node_name
}

module "databases" {
  source    = "./databases"
  node_name = var.pve_node_name
  ips       = var.lxc_ips
}

module "gateways" {
  source    = "./gateways"
  node_name = var.pve_node_name
  ips       = var.lxc_ips
}

module "media" {
  source    = "./media"
  node_name = var.pve_node_name
  ips       = var.lxc_ips
}

module "dev" {
  source    = "./dev"
  node_name = var.pve_node_name
}

module "templates" {
  source    = "./templates"
  node_name = var.pve_node_name
}

module "one_offs" {
  source    = "./one-offs"
  node_name = var.pve_node_name
  ips       = var.lxc_ips
}

module "ci" {
  source                         = "./ci"
  node_name                      = var.pve_node_name
  forgejo_runner_uuid            = var.forgejo_runner_uuid
  forgejo_runner_token           = var.forgejo_runner_token
  forgejo_runner_debian_password = var.forgejo_runner_debian_password
}
