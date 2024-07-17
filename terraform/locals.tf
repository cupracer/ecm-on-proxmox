locals {
  cluster_name            = var.cluster_name
  dnsdomain               = var.dnsdomain

  num_cluster_nodes       = var.num_cluster_nodes
  num_control_planes      = var.num_control_planes
  
  root_public_keys        = [ for key in split("\n", file(var.root_authorized_keys_file)) : key if key != "" ]
  root_private_key        = file(var.root_ssh_private_key_file)

  downstream_cluster_fqdn = var.downstream_cluster_name != null ? "${var.downstream_cluster_name}.${local.dnsdomain}" : null

  #### AUTOMATED VALUES BELOW ####

  proxy_node_hostname     = local.cluster_name
  cluster_node_hostnames  = [for i in range(local.num_cluster_nodes) : "${local.cluster_name}node${i + 1}"]
  num_workers             = local.num_cluster_nodes - local.num_control_planes

  proxies_map = {
      "${local.proxy_node_hostname}" = {
        "fqdn"         = "${local.proxy_node_hostname}.${local.dnsdomain}",
        "node_type"    = "proxy",
        "cpu_cores"    = 2,
        "memory_m"     = 2048,
        "disk_size_gb" = 30,
      }
    }

  filtered_control_plane_hostnames = slice(local.cluster_node_hostnames, 0, local.num_control_planes)
  control_planes_map = {
    for hostname in local.filtered_control_plane_hostnames :
      hostname => {
        "fqdn"         = "${hostname}.${local.dnsdomain}",
        "node_type"    = "control_plane",
        "cpu_cores"    = 4,
        "memory_m"     = 16384
        "disk_size_gb" = 30,
      }
    }

  filtered_worker_hostnames = slice(local.cluster_node_hostnames, local.num_control_planes, length(local.cluster_node_hostnames))
  workers_map = {
    for hostname in local.filtered_worker_hostnames :
      hostname => {
        "fqdn"         = "${hostname}.${local.dnsdomain}",
        "node_type"    = "worker",
        "cpu_cores"    = 4,
        "memory_m"     = 16384,
        "disk_size_gb" = 30,
      }
  }


  #### LIKE OUTPUTS ####

  cluster_nodes_map       = merge(local.proxies_map, local.control_planes_map, local.workers_map)

  primary_master_hostname = "${local.cluster_node_hostnames[0]}"
  primary_master_fqdn     = "${local.primary_master_hostname}.${local.dnsdomain}"
  primary_master_host     = module.nodes[local.primary_master_hostname].default_ipv4_address
  cluster_fqdn            = values(local.proxy_nodes)[0].fqdn # TODO: REPLACE WORKAROUND AND CHOOSE A REAL LB ADDRESS

  proxy_nodes             = { for i, n in module.nodes : i => n if n.node_type == "proxy" }
  control_plane_nodes     = { for i, n in module.nodes : i => n if n.node_type == "control_plane" }
  
  worker_nodes            = { for i, n in module.nodes : i => n if n.node_type == "worker" }
}

