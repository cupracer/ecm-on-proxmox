locals {
  cluster_prefix          = var.cluster_prefix
  hostname_base           = var.hostname_base
  dnsdomain               = var.dnsdomain

  num_gateways            = var.num_gateways
  num_cluster_nodes       = var.num_cluster_nodes
  num_control_planes      = var.num_control_planes
  
  root_public_keys        = [ for key in split("\n", file(var.root_authorized_keys_file)) : key if key != "" ]

  #### AUTOMATED VALUES BELOW ####

  gateway_node_hostnames  = [for i in range(local.num_gateways) : "${local.cluster_prefix}gateway${i + 1}"]
  cluster_name            = "${local.cluster_prefix}${local.hostname_base}"
  cluster_node_hostnames  = [for i in range(local.num_cluster_nodes) : "${local.cluster_name}${i + 1}"]
  num_workers             = local.num_cluster_nodes - local.num_control_planes

  filtered_gateway_hostnames = slice(local.gateway_node_hostnames, 0, local.num_gateways)
  gateways_map = {
    for hostname in local.filtered_gateway_hostnames :
      hostname => {
        "fqdn"         = "${hostname}.${local.dnsdomain}",
        "node_type"    = "gateway",
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
        "cpu_cores"    = 2,
        "memory_m"     = 8192,
        "disk_size_gb" = 30,
      }
    }

  filtered_worker_hostnames = slice(local.cluster_node_hostnames, local.num_control_planes, length(local.cluster_node_hostnames))
  workers_map = {
    for hostname in local.filtered_worker_hostnames :
      hostname => {
        "fqdn"         = "${hostname}.${local.dnsdomain}",
        "node_type"    = "worker",
        "cpu_cores"    = 2,
        "memory_m"     = 4096,
        "disk_size_gb" = 30,
      }
  }

  cluster_nodes_map       = merge(local.gateways_map, local.control_planes_map, local.workers_map)

  primary_master_hostname = "${local.cluster_node_hostnames[0]}"
  primary_master_fqdn     = "${local.primary_master_hostname}.${local.dnsdomain}"
  primary_master_host     = module.nodes[local.primary_master_hostname].default_ipv4_address
}

