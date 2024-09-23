variable "nodes" {
  type = map
}

variable "control_planes_fqdn" {
  type = list
}

variable "ssh_private_key" {
  type = string
}

variable "bastion_host" {
  type     = string
  nullable = true
  default  = null
}

