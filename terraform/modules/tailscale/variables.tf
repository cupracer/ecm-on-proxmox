variable "ssh_private_key" {
  type = string
}

variable "bastion_host" {
  type     = string
  nullable = true
  default  = null
}

# TODO: RENAME, BECAUSE IT'S AN IP?
variable "primary_master_host" {
  type = string
}

variable "tailscale_oauth_client_id" {
  type = string
}

variable "tailscale_oauth_client_secret" {
  type = string
}

variable "tailscale_user" {
  type = string
}

variable "cluster_name" {
  type = string
}