variable "proxy_nodes" {
  type = map
}

variable "cluster_name" {
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

variable "k3s_version" {
  type = string
}

