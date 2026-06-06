locals {
  cloud_init = {
    datastore_id = "fast-storage"
    interface    = "ide2"
    upgrade      = true
    ipv4         = { address = "dhcp" }
    user_account = {
      username = "debian"
      keys     = []
    }
  }
}
