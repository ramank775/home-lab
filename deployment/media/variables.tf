variable "namespace" {
  type    = string
  default = "media"
}

variable "media_storage" {
  type = map(string)
  default = {
    "host"     = "10.0.0.40"
    "path"     = "bigbox"
    "capacity" = "1000Gi"
  }
}

variable "domains" {
  type = map(string)
  default = {
    "media-mgmt" = "media-mgmt.homelab.arpa"
    "prowlarr"   = "tracker.homelab.arpa"
    "jellyseerr" = "jellyseerr.homelab.arpa"
  }
}
