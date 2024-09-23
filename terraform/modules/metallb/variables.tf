variable "metallb_chart_version" {
  type = string
}

variable "control_plane" {
  type = string
}

variable "ssh_private_key" {
  type = string
}

variable "address_range" {
  type = string
}

variable "l2advertisement_name" {
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
