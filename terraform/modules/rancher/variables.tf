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

variable "control_plane" {
  type = string
}

variable "ca_cert_path" {
  type = string
}

variable "ca_key_path" {
  type = string
}

variable "ssh_private_key" {
  type = string
}

variable "kubernetes_engine" {
  type    = string
  default = null
}
