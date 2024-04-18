variable "control_plane_nodes" {
  type = map
}

variable "worker_nodes" {
  type = map
}

variable "ssh_private_key" {
  type = string
}

variable "registration_command" {
  type = string
}

