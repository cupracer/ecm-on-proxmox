variable "control_plane_nodes" {
  type = map
}

variable "worker_nodes" {
  type = map
}

variable "proxy_nodes" {
  type = map
}

variable "ssh_private_key" {
  type = string
}

variable "registration_command" {
  type = string
}

# TODO: RENAME, BECAUSE IT'S AN IP?
variable "primary_master_host" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "kubernetes_engine" {
  type    = string
  default = null
}

variable "bastion_host" {
  type     = string
  nullable = true
  default  = null
}
