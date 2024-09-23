variable "proxy_nodes" {
  type = map
}

variable "ssh_private_key" {
  type = string
}

variable "parent_dns" {
  type    = list(string)
  default = []
}

variable "bastion_host" {
  type     = string
  nullable = true
  default  = null
}

