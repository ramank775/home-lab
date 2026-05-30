module "templates" {
  source    = "./templates"
  node_name = var.pve_node_name
}

module "vms" {
  source    = "./vms"
  node_name = var.pve_node_name
}
