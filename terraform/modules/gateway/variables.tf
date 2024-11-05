variable "nodes" {
  type = map
}

variable "ssh_private_key" {
  type = string
}

variable "bastion_host" {
  type     = string
  nullable = true
  default  = null
}

