variable "system_upgrade_controller_version" {
  type = string
}

variable "control_plane" {
  type = string
}

variable "ssh_private_key" {
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
