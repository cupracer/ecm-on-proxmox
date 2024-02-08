module "proxies" {
  source = "./modules/reverse_proxy"

  ssh_private_key = local.root_private_key
  nodes = local.proxy_nodes
  control_planes_fqdn = [for entry in local.control_planes_map : entry.fqdn]
}

