locals {
  register_control_plane_nodes = { for k, v in var.control_plane_nodes : k => v if length(var.control_plane_nodes) > 1 }
  register_worker_nodes        = { for k, v in var.worker_nodes : k => v if length(var.worker_nodes) > 1 }
}

resource "ssh_resource" "register_control_planes" {
  for_each     = local.register_control_plane_nodes

  host         = each.value.default_ipv4_address
  port         = 22
  user         = "root"
  private_key  = var.ssh_private_key

  commands = [
    "${var.registration_command} --etcd --controlplane",
  ]
}

resource "ssh_resource" "register_workers" {
  for_each     = local.register_worker_nodes

  host         = each.value.default_ipv4_address
  port         = 22
  user         = "root"
  private_key  = var.ssh_private_key

  commands = [
    "${var.registration_command} --worker",
  ]
}

