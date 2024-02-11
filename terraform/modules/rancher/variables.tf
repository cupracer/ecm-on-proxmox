variable "cert_manager_chart_version" {
  type = string
}

variable "rancher_chart_url" {
  type = string
}

variable "rancher_password" {
  type      = string
  sensitive = true
}

variable "cluster_fqdn" {
  type = string
}

variable "control_plane_nodes" {
  type = map
}

