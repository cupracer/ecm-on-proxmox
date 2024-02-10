module "proxies" {
  depends_on = [ module.nodes ]
  source     = "./modules/reverse_proxy"

  ssh_private_key     = local.root_private_key
  nodes               = local.proxy_nodes
  control_planes_fqdn = [for entry in local.control_planes_map : entry.fqdn]
}

module "k3s" {
  depends_on = [ module.proxies ]
  source     = "./modules/k3s"

  ssh_private_key     = local.root_private_key
  proxy_nodes         = local.proxy_nodes
  cluster_name        = local.cluster_name
  control_plane_nodes = local.control_plane_nodes
  worker_nodes        = local.worker_nodes
  set_taints          = true # TODO: MAKE CONFIGURABLE
  primary_master_fqdn = local.primary_master_fqdn
  primary_master_host = local.primary_master_host
  k3s_version         = var.k3s_version
}

provider "helm" {
  kubernetes {
    config_path = module.k3s.kube_config_server_yaml.filename
  }
}

module "kured" {
  depends_on = [ module.k3s ]
  count      = var.kured_version != null ? 1 : 0
  source     = "./modules/kured"

  ssh_private_key     = local.root_private_key
  control_plane_nodes = local.control_plane_nodes
  worker_nodes        = local.worker_nodes
  kured_version       = var.kured_version
}

module "metallb" {
  depends_on = [ module.k3s ]
  count      = var.metallb_version != null ? 1 : 0
  source     = "./modules/metallb"

  metallb_version = var.metallb_version
}

module "argocd" {
  depends_on = [ module.k3s ]
  count      = var.argocd_version != null ? 1 : 0
  source     = "./modules/argocd"

  argocd_version = var.argocd_version
  service_type   = "ClusterIP"
}

module "traefik" {
  depends_on = [ module.k3s ]
  count      = var.traefik_version != null ? 1 : 0
  source     = "./modules/traefik"

  traefik_version = var.traefik_version
}

