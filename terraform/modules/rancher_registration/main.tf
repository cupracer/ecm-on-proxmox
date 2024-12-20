locals {
  register_control_plane_nodes = { for k, v in var.control_plane_nodes : k => v if length(var.control_plane_nodes) > 1 }
  register_worker_nodes        = { for k, v in var.worker_nodes : k => v if length(var.worker_nodes) > 1 }
  random_proxy_node            = values(var.proxy_nodes)[0]  #TODO: THIS IS FAKE AND NEEDS TO BE FIXED (NO RANDOM NEEDED)
  cluster_port                 = var.kubernetes_engine == "rke2" ? 9345 : 6443
  cluster_url                  = "https://${local.random_proxy_node.fqdn}:${local.cluster_port}"
}

resource "ssh_resource" "additional_packages" {
  for_each = merge(local.register_control_plane_nodes, local.register_worker_nodes)

  host        = each.value.cluster_ipv4_address
  bastion_host = var.bastion_host
  port        = 22
  user        = "root"
  private_key = var.ssh_private_key

  commands = [<<-EOT
    transactional-update --no-selfupdate shell <<< "
      zypper --gpg-auto-import-keys install -y cri-tools kubernetes-client llvm clang"
    systemctl stop sshd.service && reboot
        EOT
  ]
}

resource "ssh_resource" "register_control_planes" {
  depends_on   = [ ssh_resource.additional_packages, ]
  for_each     = local.register_control_plane_nodes

  host         = each.value.public_ipv4_address
  bastion_host = var.bastion_host
  port         = 22
  user         = "root"
  private_key  = var.ssh_private_key

  commands = [
    "${var.registration_command} --etcd --controlplane",
    "mkdir -p /root/.kube",
    "ln -sf /etc/rancher/${var.kubernetes_engine}/${var.kubernetes_engine}.yaml /root/.kube/config",
  ]
}

resource "ssh_resource" "register_workers" {
  depends_on   = [ ssh_resource.additional_packages, ]
  for_each     = local.register_worker_nodes

  host         = each.value.public_ipv4_address
  bastion_host = var.bastion_host
  port         = 22
  user         = "root"
  private_key  = var.ssh_private_key

  commands = [
    "${var.registration_command} --worker",
  ]
}

####

resource "ssh_resource" "retrieve_cluster_config" {
  depends_on = [ ssh_resource.register_control_planes ]

  host         = var.primary_master_host
  bastion_host = var.bastion_host
  port         = 22
  user         = "root"
  private_key  = var.ssh_private_key

  # TODO: DEFINE A CLUSTER FQDN INSTEAD OF POINTING TO A SINGLE PROXY DIRECTLY
  commands = [
    "sudo sed \"s/127.0.0.1/${local.random_proxy_node.fqdn}/g\" /etc/rancher/${var.kubernetes_engine}/${var.kubernetes_engine}.yaml"
  ]
}

resource "local_file" "kube_config_server_yaml" {
  depends_on = [
    ssh_resource.retrieve_cluster_config
  ]

  filename = format("%s/%s", path.root, "kube_config_${var.cluster_name}.yaml")
  file_permission = "0600"
  content  = ssh_resource.retrieve_cluster_config.result
}

resource "null_resource" "wait_for_kubernetes" {
  depends_on = [ local_file.kube_config_server_yaml, ]

  provisioner "local-exec" {
    command     = <<-EOF
    count=0
    while [ "$${count}" -lt 5 ]; do
      resp=$(curl -k -s -o /dev/null -w "%%{http_code}" $${CLUSTER_URL}/ping)
      echo "Waiting for $${CLUSTER_URL}/ping - response: $${resp}"
      if [ "$${resp}" = "200" ]; then
        ((count++))
      fi
      sleep 2
    done
    EOF
    interpreter = ["/bin/bash", "-c"]
    environment = {
      CLUSTER_URL = local.cluster_url
    }
  }
}

