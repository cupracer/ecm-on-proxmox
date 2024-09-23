variable "control_plane_nodes" {
  type = map
}

variable "worker_nodes" {
  type = map
}

variable "ssh_private_key" {
  type = string
}

variable "kured_chart_version" {
  type = string
}

variable "bastion_host" {
  type     = string
  nullable = true
  default  = null
}
