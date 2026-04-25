variable "namespace" {
  type        = string
  description = "Namespace for monitoring resources"
  default     = "monitoring"
}

variable "domain" {
  type        = string
  description = "Internal service domain"
  default     = "monitoring.homelab.arpa"
}

variable "storageClassName" {
  type        = string
  description = "Persistence storage class name"
  default     = "truenas-iscsi-csi"
}

variable "external_ips" {
  type        = map(string)
  description = "External IP for monitoring Stack for ingress"
}

variable "config_dir" {
  type        = string
  description = "Directory contains configuration files for monitoring"

}

variable "minio_endpoint" {
  type        = string
  description = "Minio endpoint for monitoring stack"
}

variable "prometheus_chart_version" {
  type        = string
  description = "Helm chart version for kube-prometheus-stack/prometheus"
}

variable "loki_chart_version" {
  type        = string
  description = "Helm chart version for loki"
}

variable "tempo_chart_version" {
  type        = string
  description = "Helm chart version for tempo"
}

variable "pyroscope_chart_version" {
  type        = string
  description = "Helm chart version for pyroscope"
}

variable "grafana_chart_version" {
  type        = string
  description = "Helm chart version for grafana"
}

variable "alloy_chart_version" {
  type        = string
  description = "Helm chart version for grafana-alloy"
}

variable "graphite_exporter_image_tag" {
  type        = string
  description = "Image tag for the prometheus graphite-exporter"
}