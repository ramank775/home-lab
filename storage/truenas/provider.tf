provider "truenas" {
  url                  = var.truenas_url
  api_key              = var.truenas_api_key
  insecure_skip_verify = var.truenas_allow_insecure
}
