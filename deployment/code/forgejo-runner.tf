locals {
  # https://code.forgejo.org/forgejo/runner/releases
  forgejo_runner_version = "v6.3.1"

  # Internal metallb VIP for forgejo — same address as the Helm release's service.
  forgejo_instance_url = "http://${var.forgejo_ip}:3000"

  cloud_init = {
    datastore_id = "fs-1"
    interface    = "ide2"
    upgrade      = true
    ipv4         = { address = "dhcp" }
    # No user_account: rely on the template's baked-in `debian` user + password.
  }
}

resource "proxmox_virtual_environment_file" "forgejo_runner_user_data" {
  content_type = "snippets"
  datastore_id = "local-snippets"
  node_name    = var.node_name

  source_raw {
    file_name = "forgejo-runner-1-user-data.yaml"
    data = templatefile("${path.module}/cloud-init/forgejo-runner.yaml.tftpl", {
      hostname           = "forgejo-runner-1"
      runner_version     = local.forgejo_runner_version
      forgejo_url        = local.forgejo_instance_url
      runner_uuid        = var.forgejo_runner_uuid
      runner_token       = var.forgejo_runner_token
      runner_concurrency = 3
      node_image         = var.forgejo_runner_node_image
      forgejo_host       = var.public_host
      forgejo_ip         = var.public_gateway_ip
      debian_password    = var.forgejo_runner_debian_password
    })
  }
}

module "forgejo_runner_1" {
  source    = "../../tf-modules/proxmox-vm"
  name      = "forgejo-runner-1"
  node_name = var.node_name
  vm_id     = 6000
  on_boot   = true
  tags      = ["ci", "forgejo-runner"]

  clone = { vm_id = 90000 } # debian-cloud template

  cpu    = { cores = 4, hotplugged = 4 }
  memory = { dedicated = 8192, floating = 4096 }

  disks = [{
    datastore_id = "fs-1"
    interface    = "scsi0"
    size         = 50
  }]

  network_devices = [{
    bridge = "vmbr0"
  }]

  agent = { enabled = true }

  cloud_init = merge(local.cloud_init, {
    user_data_file_id = proxmox_virtual_environment_file.forgejo_runner_user_data.id
  })
}
