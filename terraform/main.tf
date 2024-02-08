module "proxies" {
  source = "./modules/reverse_proxy"

  ssh_private_key = local.root_private_key
  nodes = local.proxy_nodes 
}

