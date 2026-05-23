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
    "metube"     = "metube.homelab.arpa"
  }
}

variable "sonarr_image_tag" {
  type        = string
  description = "Container image tag for sonarr"
}

variable "radarr_image_tag" {
  type        = string
  description = "Container image tag for radarr"
}

variable "prowlarr_image_tag" {
  type        = string
  description = "Container image tag for prowlarr"
}

variable "jellyseerr_image_tag" {
  type        = string
  description = "Container image tag for jellyseerr"
}

variable "flaresolverr_image_tag" {
  type        = string
  description = "Container image tag for flaresolverr"
}

variable "metube_image_tag" {
  type        = string
  description = "Container image tag for metube"
}
