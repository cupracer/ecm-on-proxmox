locals {
  root_public_keys = [ for key in try(split("\n", file(var.ci_root_authorized_keys_file)), []) : key if key != "" ]
  ssh_private_key  = file(var.ssh_private_key_file)

  cluster_prefix          = "c1"
  hostname_base           = "down"
  dnsdomain               = "int.team-schulte.com"
  num_nodes               = 2
  num_control_planes      = 1 

  #### AUTOMATED VALUES BELOW ####

  cluster_name            = "${local.cluster_prefix}${local.hostname_base}"
  num_workers             = local.num_nodes - local.num_control_planes
  hostnames               = [for i in range(local.num_nodes) : "${local.cluster_name}${i + 1}"]

  filtered_control_plane_hostnames = slice(local.hostnames, 0, local.num_control_planes)
  control_planes_map = {
    for hostname in local.filtered_control_plane_hostnames :
      hostname => {
        "fqdn"         = "${hostname}.${local.dnsdomain}",
        "node_type"    = "control_plane",
        "cpu_sockets"  = 1,
        "cpu_cores"    = 2,
        "memory_m"     = 8192,
        "disk_size_gb" = 20,
      }
    }

  filtered_worker_hostnames = slice(local.hostnames, local.num_control_planes, length(local.hostnames))
  workers_map = {
    for hostname in local.filtered_worker_hostnames :
      hostname => {
        "fqdn"         = "${hostname}.${local.dnsdomain}",
        "node_type"    = "worker",
        "cpu_sockets"  = 1,
        "cpu_cores"    = 2,
        "memory_m"     = 4096,
        "disk_size_gb" = 40,
      }
  }

  cluster_nodes_map       = merge(local.control_planes_map, local.workers_map)

  primary_master_hostname = "${local.hostnames[0]}"
  primary_master_fqdn     = "${local.primary_master_hostname}.${local.dnsdomain}"
  primary_master_host     = module.nodes[local.primary_master_hostname].default_ipv4_address
}


module "nodes" {
  for_each               = local.cluster_nodes_map

  source                 = "./modules/node"
  proxmox_node           = var.proxmox_node
  vm_template            = "opensuse-microos"
  vm_name                = each.key
  fqdn                   = each.value.fqdn
  vm_description         = "openSUSE MicroOS - Cluster ${local.cluster_name}"
  node_type              = each.value.node_type
  vm_cpu_sockets         = each.value.cpu_sockets
  vm_cpu_cores           = each.value.cpu_cores
  vm_memory              = each.value.memory_m
  vm_disk_size           = each.value.disk_size_gb
  storage_pool           = var.storage_pool
  iso_storage_pool       = var.iso_storage_pool
  network_bridge         = var.network_bridge
  root_public_keys       = local.root_public_keys
  ci_root_lock_password  = var.ci_root_lock_password
  ci_root_plain_password = var.ci_root_plain_password
}

output "nodes" {
  value = module.nodes
  sensitive = true
}

