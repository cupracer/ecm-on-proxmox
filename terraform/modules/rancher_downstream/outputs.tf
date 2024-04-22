output "node_command" {
  value = rancher2_cluster_v2.create_downstream_cluster.cluster_registration_token[0].node_command
  sensitive = true
}

output "node_command_insecure" {
  value = rancher2_cluster_v2.create_downstream_cluster.cluster_registration_token[0].insecure_node_command
  sensitive = true
}

