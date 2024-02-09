module "proxies" {
  source = "./modules/reverse_proxy"

  ssh_private_key = local.root_private_key
  nodes = local.proxy_nodes
  control_planes_fqdn = [for entry in local.control_planes_map : entry.fqdn]
}

module "k3s" {
  source = "./modules/k3s"

  ssh_private_key = local.root_private_key
  proxy_nodes = local.proxy_nodes
  cluster_name = local.cluster_name
  control_plane_nodes = local.control_plane_nodes
  worker_nodes = local.worker_nodes
  set_taints = true # TODO: MAKE CONFIGURABLE
  primary_master_fqdn = local.primary_master_fqdn
  primary_master_host = local.primary_master_host
}

