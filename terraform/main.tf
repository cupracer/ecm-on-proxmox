module "proxies" {
  depends_on = [ module.nodes ]
  source     = "./modules/reverse_proxy"

  ssh_private_key     = local.root_private_key
  nodes               = local.proxy_nodes
  control_planes_fqdn = [for entry in local.control_planes_map : entry.fqdn]
}

module "rancher_registration" {
  depends_on = [ module.proxies ]
  count      = var.registration_command != null ? 1: 0
  source     = "./modules/rancher_registration"

  ssh_private_key       = local.root_private_key
  control_plane_nodes   = local.control_plane_nodes
  worker_nodes          = local.worker_nodes
  proxy_nodes           = local.proxy_nodes
  primary_master_host   = local.primary_master_host
  registration_command  = var.registration_command
  cluster_name          = local.cluster_name
}

module "k3s" {
  depends_on = [ module.proxies ]
  count      = var.k3s_version != null && var.registration_command == null ? 1 : 0
  source     = "./modules/k3s"

  ssh_private_key       = local.root_private_key
  proxy_nodes           = local.proxy_nodes
  cluster_name          = local.cluster_name
  cluster_fqdn          = local.cluster_fqdn
  control_plane_nodes   = local.control_plane_nodes
  worker_nodes          = local.worker_nodes
  set_taints            = (local.num_workers > 0)
  primary_master_fqdn   = local.primary_master_fqdn
  primary_master_host   = local.primary_master_host
  k3s_version           = var.k3s_version
  disable_k3s_servicelb = (var.metallb_chart_version != null)
  disable_k3s_traefik   = (var.traefik_chart_version != null)
}

provider "helm" {
  kubernetes {
    config_path = length(module.rancher_registration) > 0 ? module.rancher_registration[0].kube_config_server_yaml.filename : ( length(module.k3s) > 0 ? module.k3s[0].kube_config_server_yaml.filename : null )
  }
}

module "kured" {
  depends_on = [ module.k3s, module.rancher_registration, ]
  count      = var.kured_chart_version != null ? 1 : 0
  source     = "./modules/kured"

  ssh_private_key     = local.root_private_key
  control_plane_nodes = local.control_plane_nodes
  worker_nodes        = local.worker_nodes
  kured_chart_version = var.kured_chart_version
}

module "metallb" {
  depends_on = [ module.k3s, module.rancher_registration, ]
  count      = var.metallb_chart_version != null ? 1 : 0
  source     = "./modules/metallb"

  metallb_chart_version = var.metallb_chart_version
  control_plane         = local.primary_master_host
  ssh_private_key       = local.root_private_key

  address_range        = var.metallb_address_range
  l2advertisement_name = var.metallb_l2advertisement_name
}

module "argocd" {
  depends_on = [ module.k3s, module.rancher_registration, ]
  count      = var.argocd_chart_version != null ? 1 : 0
  source     = "./modules/argocd"

  argocd_chart_version = var.argocd_chart_version
  service_type         = "LoadBalancer" # TOOD: MAKE CONFIGURABLE
}

module "traefik" {
  depends_on = [ module.k3s, module.rancher_registration, ]
  count      = var.traefik_chart_version != null ? 1 : 0
  source     = "./modules/traefik"

  traefik_chart_version = var.traefik_chart_version
}

module "system_upgrade_controller" {
  depends_on = [ module.k3s, module.rancher_registration, ]
  count      = var.system_upgrade_controller_version != null ? 1 : 0
  source     = "./modules/system_upgrade_controller"

  control_plane         = local.primary_master_host
  ssh_private_key       = local.root_private_key

  system_upgrade_controller_version = var.system_upgrade_controller_version
}

########

provider "rancher2" {
  alias = "bootstrap"

  api_url  = "https://${local.cluster_fqdn}"
  insecure = true
  bootstrap = true
}

module "rancher" {
  depends_on = [ module.k3s ]
  count      = var.rancher_chart_url != null ? 1 : 0
  source     = "./modules/rancher"

  providers = {
    rancher2 = rancher2.bootstrap
  }

  rancher_chart_url          = var.rancher_chart_url
  cert_manager_chart_version = var.cert_manager_chart_version
  rancher_password           = var.rancher_password
  cluster_fqdn               = local.cluster_fqdn
  control_plane_nodes        = local.control_plane_nodes

  ssh_private_key            = local.root_private_key
  control_plane              = local.primary_master_host
  ca_key_path                = var.ca_key_path
  ca_cert_path               = var.ca_cert_path
}

provider "rancher2" {
  alias = "admin"

  api_url  = "https://${local.cluster_fqdn}"
  insecure = false
  # ca_certs  = data.kubernetes_secret.rancher_cert.data["ca.crt"]
  token_key = module.rancher[0].rancher_token
  timeout   = "300s"
}

resource "rancher2_cluster_v2" "create_downstream_cluster" {
  depends_on = [ module.rancher, ]

  count    = var.rancher_prepare_downstream ? 1 : 0
  provider = rancher2.admin

  name = var.downstream_cluster_name
  kubernetes_version = var.k3s_version
}
