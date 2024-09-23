locals {
  register_control_plane_nodes = { for k, v in var.control_plane_nodes : k => v if length(var.control_plane_nodes) > 1 }
  register_worker_nodes        = { for k, v in var.worker_nodes : k => v if length(var.worker_nodes) > 1 }
  random_proxy_node            = values(var.proxy_nodes)[0]  #TODO: THIS IS FAKE AND NEEDS TO BE FIXED (NO RANDOM NEEDED)
  cluster_url                  = "https://${local.random_proxy_node.fqdn}:6443"
}

resource "ssh_resource" "register_control_planes" {
  for_each     = local.register_control_plane_nodes

  host         = each.value.public_ipv4_address
  bastion_host = var.bastion_host
  port         = 22
  user         = "root"
  private_key  = var.ssh_private_key

  commands = [
    "${var.registration_command} --etcd --controlplane",
  ]
}

resource "ssh_resource" "register_workers" {
  for_each     = local.register_worker_nodes

  host         = each.value.public_ipv4_address
  bastion_host = var.bastion_host
  port         = 22
  user         = "root"
  private_key  = var.ssh_private_key

  commands = [
    "${var.registration_command} --worker",
  ]
}

####

resource "ssh_resource" "retrieve_cluster_config" {
  depends_on = [ ssh_resource.register_control_planes ]

  host         = var.primary_master_host
  bastion_host = var.bastion_host
  port         = 22
  user         = "root"
  private_key  = var.ssh_private_key

  # TODO: DEFINE A CLUSTER FQDN INSTEAD OF POINTING TO A SINGLE PROXY DIRECTLY
  commands = [
    "sudo sed \"s/127.0.0.1/${local.random_proxy_node.fqdn}/g\" /etc/rancher/${var.kubernetes_engine}/${var.kubernetes_engine}.yaml"
  ]
}

resource "local_file" "kube_config_server_yaml" {
  depends_on = [
    ssh_resource.retrieve_cluster_config
  ]

  filename = format("%s/%s", path.root, "kube_config_${var.cluster_name}.yaml")
  file_permission = "0600"
  content  = ssh_resource.retrieve_cluster_config.result
}

data "http" "kubernetes" {
  depends_on = [ local_file.kube_config_server_yaml, ]

  url = "${local.cluster_url}/ping"
  insecure = true

  retry {
    attempts = 10
    min_delay_ms = 1000
    max_delay_ms = 3000
  }
}
