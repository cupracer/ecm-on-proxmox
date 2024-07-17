variable "cluster_name" {
  type = string
}

variable "dnsdomain" {
  type = string
}

variable "num_cluster_nodes" {
  type = number
}

variable "num_control_planes" {
  type = number
}

variable "root_ssh_private_key_file" {
  type = string
}

variable "root_authorized_keys_file" {
  type = string
}

variable "node_root_lock_password" {
  type = bool
}

variable "node_root_plain_password" {
  type      = string
  sensitive = true
}

variable "kubernetes_engine" {
  type    = string
  default = null
}

variable "kubernetes_engine_version" {
  type    = string
  default = null
}

variable "use_selinux" {
  type    = bool
  default = true
}

variable "kured_chart_version" {
  type    = string
  default = null
}

variable "metallb_chart_version" {
  type    = string
  default = null
}

variable "metallb_address_range" {
  type    = string
  default = null
}

variable "metallb_l2advertisement_name" {
  type    = string
  default = null
}

variable "argocd_chart_version" {
  type    = string
  default = null
}

variable "traefik_chart_version" {
  type    = string
  default = null
}

variable "system_upgrade_controller_version" {
  type    = string
  default = null
}

variable "cert_manager_chart_version" {
  type    = string
  default = null
}

variable "rancher_chart_url" {
  type    = string
  default = null
}

variable "rancher_password" {
  type    = string
  default = null
}

variable "rancher_prepare_downstream" {
  type    = bool
  default = false
}

variable "downstream_cluster_name" {
  type    = string
  default = null
}

variable "registration_command" {
  type    = string
  default = null
}

variable "ca_key_path" {
  type    = string
  default = null
}

variable "ca_cert_path" {
  type    = string
  default = null
}

variable "setup_dnsmasq" {
  type    = bool
  default = false
}

variable "dnsmasq_parent_dns" {
  type    = list(string)
  default = []
}

variable "dnsmasq_servers" {
  type    = list(string)
  default = []
}

