module "proxies" {
  depends_on = [module.nodes]
  source     = "./modules/reverse_proxy"

  ssh_private_key     = local.root_private_key
  nodes               = local.proxy_nodes
  control_planes_fqdn = [for entry in local.control_planes_map : entry.fqdn]
}

module "dnsmasq" {
  depends_on = [module.proxies, ]
  count      = var.setup_dnsmasq ? 1 : 0
  source     = "./modules/dnsmasq"

  ssh_private_key = local.root_private_key
  proxy_nodes     = local.proxy_nodes
  parent_dns      = var.dnsmasq_parent_dns
}

module "dnsmasq_hosts" {
  depends_on = [module.dnsmasq, ]
  count      = var.setup_dnsmasq || length(var.dnsmasq_servers) > 0 ? 1 : 0
  source     = "./modules/dnsmasq_hosts"

  ssh_private_key = local.root_private_key
  proxy_nodes     = local.proxy_nodes
  cluster_nodes   = merge(local.control_plane_nodes, local.worker_nodes)
  cluster_name    = var.cluster_name
  dnsmasq_servers = var.dnsmasq_servers
  dnsdomain       = local.dnsdomain
}

module "rancher_registration" {
  depends_on = [module.proxies]
  count      = var.registration_command != null ? 1 : 0
  source     = "./modules/rancher_registration"

  ssh_private_key      = local.root_private_key
  control_plane_nodes  = local.control_plane_nodes
  worker_nodes         = local.worker_nodes
  proxy_nodes          = local.proxy_nodes
  primary_master_host  = local.primary_master_host
  registration_command = var.registration_command
  cluster_name         = local.cluster_name
  kubernetes_engine           = var.kubernetes_engine
}

module "kubernetes" {
  depends_on = [module.proxies]
  count      = var.kubernetes_engine_version != null && var.registration_command == null ? 1 : 0
  source     = "./modules/kubernetes"

  ssh_private_key       = local.root_private_key
  proxy_nodes           = local.proxy_nodes
  cluster_name          = local.cluster_name
  cluster_fqdn          = local.cluster_fqdn
  control_plane_nodes   = local.control_plane_nodes
  worker_nodes          = local.worker_nodes
  set_taints            = (local.num_workers > 0)
  primary_master_fqdn   = local.primary_master_fqdn
  primary_master_host   = local.primary_master_host
  kubernetes_engine           = var.kubernetes_engine
  kubernetes_engine_version           = var.kubernetes_engine_version
  use_selinux           = var.use_selinux
  use_servicelb = !(var.metallb_chart_version != null)
  use_traefik   = !(var.traefik_chart_version != null)
}

provider "helm" {
  kubernetes {
    config_path = length(module.rancher_registration) > 0 ? module.rancher_registration[0].kube_config_server_yaml.filename : ( length(module.kubernetes) > 0 ? module.kubernetes[0].kube_config_server_yaml.filename : null )
  }
}

module "kured" {
  depends_on = [module.kubernetes, module.rancher_registration, ]
  count      = var.kured_chart_version != null ? 1 : 0
  source     = "./modules/kured"

  ssh_private_key     = local.root_private_key
  control_plane_nodes = local.control_plane_nodes
  worker_nodes        = local.worker_nodes
  kured_chart_version = var.kured_chart_version
}

module "metallb" {
  depends_on = [module.kubernetes, module.rancher_registration, ]
  count      = var.metallb_chart_version != null ? 1 : 0
  source     = "./modules/metallb"

  metallb_chart_version = var.metallb_chart_version
  control_plane         = local.primary_master_host
  ssh_private_key       = local.root_private_key
  kubernetes_engine           = var.kubernetes_engine

  address_range        = var.metallb_address_range
  l2advertisement_name = var.metallb_l2advertisement_name
}

module "argocd" {
  depends_on = [module.kubernetes, module.rancher_registration, ]
  count      = var.argocd_chart_version != null ? 1 : 0
  source     = "./modules/argocd"

  argocd_chart_version = var.argocd_chart_version
  service_type         = "ClusterIP" # TOOD: MAKE CONFIGURABLE IN terraform.tfvars
}

module "traefik" {
  depends_on = [module.kubernetes, module.rancher_registration, ]
  count      = var.traefik_chart_version != null ? 1 : 0
  source     = "./modules/traefik"

  traefik_chart_version = var.traefik_chart_version
}

module "system_upgrade_controller" {
  depends_on = [module.kubernetes, module.rancher_registration, ]
  count      = var.system_upgrade_controller_version != null ? 1 : 0
  source     = "./modules/system_upgrade_controller"

  control_plane   = local.primary_master_host
  ssh_private_key = local.root_private_key

  kubernetes_engine          = var.kubernetes_engine
  system_upgrade_controller_version = var.system_upgrade_controller_version
}

########

provider "rancher2" {
  alias = "bootstrap"

  api_url   = "https://${local.cluster_fqdn}"
  insecure  = true
  bootstrap = true
}

module "rancher" {
  depends_on = [module.kubernetes,]
  count      = var.rancher_chart_url != null ? 1 : 0
  source     = "./modules/rancher"

  providers = {
    rancher2 = rancher2.bootstrap
  }

  kubernetes_engine          = var.kubernetes_engine
  rancher_chart_url          = var.rancher_chart_url
  cert_manager_chart_version = var.cert_manager_chart_version
  rancher_password           = var.rancher_password
  cluster_fqdn               = local.cluster_fqdn
  proxy_nodes                = local.proxy_nodes
  control_plane_nodes        = local.control_plane_nodes

  ssh_private_key = local.root_private_key
  control_plane   = local.primary_master_host
  ca_key_path     = var.ca_key_path
  ca_cert_path    = var.ca_cert_path
}

provider "rancher2" {
  alias = "admin"

  api_url   = "https://${local.cluster_fqdn}"
  insecure  = false
  token_key = length(module.rancher) > 0 ? module.rancher[0].rancher_token : ""
  timeout   = "300s"
}

module "rancher_downstream" {
  depends_on = [module.rancher, ]
  count      = var.rancher_prepare_downstream && var.kubernetes_engine_version != null ? 1 : 0
  source     = "./modules/rancher_downstream"

  providers = {
    rancher2 = rancher2.admin
  }

  downstream_cluster_name = var.downstream_cluster_name
  kubernetes_engine_version             = var.kubernetes_engine_version
  cluster_fqdn          = local.downstream_cluster_fqdn
}

