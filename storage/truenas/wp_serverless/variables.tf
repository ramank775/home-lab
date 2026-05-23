variable "share_hosts" {
  description = "Allowed hosts for the NFS share."
  type        = list(string)
  default     = []
}
