variable "proxy_nodes" {
  type = map
}

variable "cluster_name" {
  type = string
}

variable "cluster_fqdn" {
  type = string
}

variable "control_plane_nodes" {
  type = map
}

variable "worker_nodes" {
  type = map
}

variable "ssh_private_key" {
  type = string
}

variable "use_servicelb" {
  type    = bool
}

variable "use_traefik" {
  type    = bool
}

variable "set_taints" {
  type = bool
}

variable "primary_master_fqdn" {
  type = string
}

# TODO: RENAME, BECAUSE IT'S AN IP?
variable "primary_master_host" {
  type = string
}

variable "kubernetes_engine" {
  type = string
  default = null
}

variable "kubernetes_engine_version" {
  type = string
}

variable "use_selinux" {
  type    = bool
  default = true
}

