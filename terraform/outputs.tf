output "nodes" {
  value = module.nodes
}

output "proxy_nodes" {
  value = { for i, n in module.nodes : i => n if n.node_type == "proxy" }
}

output "control_plane_nodes" {
  value = { for i, n in module.nodes : i => n if n.node_type == "control_plane" }
}

output "worker_nodes" {
  value = { for i, n in module.nodes : i => n if n.node_type == "worker" }
}

output "downstream_node_command" {
  value = can(rancher2_cluster_v2.create_downstream_cluster[0]) ? nonsensitive(one(rancher2_cluster_v2.create_downstream_cluster).cluster_registration_token[0].node_command) : null
}

#output "downstream_insecure_node_command" {
#  value = nonsensitive(rancher2_cluster_v2.create_downstream_cluster[0].cluster_registration_token[0].insecure_node_command)
#}

