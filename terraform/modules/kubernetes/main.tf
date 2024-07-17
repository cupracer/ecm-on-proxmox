locals {
  cluster_token     = random_string.cluster_token.result
  random_proxy_node = values(var.proxy_nodes)[0] #TODO: THIS IS FAKE AND NEEDS TO BE FIXED (NO RANDOM NEEDED)
  cluster_url       = "https://${local.random_proxy_node.fqdn}:6443"
  selinux_int       = var.use_selinux ? 1 : 0
  selinux_booltext  = var.use_selinux ? "true" : "false"
}

resource "random_string" "cluster_token" {
  length  = 64
  upper   = true
  special = false
}

resource "ssh_resource" "workaround_disable_selinux" {
  for_each = merge(var.control_plane_nodes, var.worker_nodes)

  host        = each.value.default_ipv4_address
  port        = 22
  user        = "root"
  private_key = var.ssh_private_key

  commands = [
    "sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT/s/ selinux=./ selinux=${local.selinux_int}/' /etc/default/grub",
    "transactional-update --no-selfupdate grub.cfg",
    "systemctl stop sshd.service && reboot",
  ]
}

resource "ssh_resource" "additional_packages" {
  depends_on = [ssh_resource.workaround_disable_selinux]

  for_each = merge(var.control_plane_nodes, var.worker_nodes)

  host        = each.value.default_ipv4_address
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

resource "ssh_resource" "setup_control_planes" {
  depends_on = [ssh_resource.additional_packages]

  for_each = var.control_plane_nodes

  host        = each.value.default_ipv4_address
  port        = 22
  user        = "root"
  private_key = var.ssh_private_key

  pre_commands = [
    "mkdir -p /etc/rancher/${var.kubernetes_engine}/config.yaml.d",
    "mkdir -p /var/lib/rancher/${var.kubernetes_engine}/server/manifests",
  ]

  file {
    destination = "/etc/rancher/${var.kubernetes_engine}/config.yaml"
    owner       = "root"
    group       = "root"
    permissions = "0640"
    content = templatefile("${path.module}/control_plane_config.yaml.tftpl", {
      fqdn              = each.value.fqdn
      cluster_token     = local.cluster_token
      cluster_fqdn      = var.cluster_fqdn
      proxy_fqdns       = [for node in var.proxy_nodes : node.fqdn]
      proxy_ipv4s       = [for node in var.proxy_nodes : node.default_ipv4_address]
      kubernetes_engine = var.kubernetes_engine
      use_servicelb     = var.use_servicelb
      use_traefik       = var.use_traefik
      set_taints        = var.set_taints
      selinux           = local.selinux_booltext
    })
  }

  # TODO: DON'T USE A RANDOM PROXY NODE; USE AN LB FQDN INSTEAD
  file {
    destination = "/etc/rancher/${var.kubernetes_engine}/config.yaml.d/server.yaml"
    owner       = "root"
    group       = "root"
    permissions = "0640"
    content = each.value.fqdn == var.primary_master_fqdn ? (<<-EOT
cluster-init: true
EOT
    ) : <<-EOT
server: ${local.cluster_url}
EOT
  }

  commands = var.kubernetes_engine == "k3s" ? [<<-EOT
    curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="${var.kubernetes_engine_version}" INSTALL_K3S_SKIP_START=true INSTALL_K3S_SKIP_SELINUX_RPM=true INSTALL_K3S_SELINUX_WARN=true sh -s - server > /var/log/curl_install_${var.kubernetes_engine}.log 2>&1

    mkdir -p /root/.kube
    ln -sf /etc/rancher/${var.kubernetes_engine}/${var.kubernetes_engine}.yaml /root/.kube/config
    systemctl stop sshd.service && reboot
    EOT
  ] : var.kubernetes_engine == "rke2" ? [<<-EOT
    curl -sfL https://get.rke2.io | INSTALL_RKE2_VERSION="${var.kubernetes_engine_version}" sh -s - server > /var/log/curl_install_${var.kubernetes_engine}.log 2>&1

    mkdir -p /root/.kube
    ln -sf /etc/rancher/${var.kubernetes_engine}/${var.kubernetes_engine}.yaml /root/.kube/config
    systemctl enable rke2-server.service
    systemctl stop sshd.service && reboot
    EOT
  ] : []
}


resource "ssh_resource" "retrieve_cluster_config" {
  depends_on = [ssh_resource.setup_control_planes]

  host        = var.primary_master_host
  port        = 22
  user        = "root"
  private_key = var.ssh_private_key

  # TODO: DEFINE A CLUSTER FQDN INSTEAD OF POINTING TO A SINGLE PROXY DIRECTLY
  commands = [
    "sudo sed \"s/127.0.0.1/${local.random_proxy_node.fqdn}/g\" /etc/rancher/${var.kubernetes_engine}/${var.kubernetes_engine}.yaml"
  ]
}

resource "local_file" "kube_config_server_yaml" {
  depends_on = [
    ssh_resource.retrieve_cluster_config
  ]

  filename        = format("%s/%s", path.root, "kube_config_${var.cluster_name}.yaml")
  file_permission = "0600"
  content         = ssh_resource.retrieve_cluster_config.result
}

# resource "null_resource" "wait_for_kubernetes" {
#   triggers = {
#     url_check = (data.http.kubernetes.request_body == "pong")
#   }
# 
#   provisioner "local-exec" {
#     command = "echo 'Cluster URL ${local.cluster_url}/ping is reachable.'"
#   }
# }
# 
# data "http" "kubernetes" {
#   depends_on = [local_file.kube_config_server_yaml, ]
# 
#   url      = "${local.cluster_url}/ping"
#   insecure = true
# 
#   retry {
#     attempts     = 10
#     min_delay_ms = 1000
#     max_delay_ms = 3000
#   }
# }

resource "ssh_resource" "setup_workers" {
  depends_on = [local_file.kube_config_server_yaml, ]

  for_each = var.worker_nodes

  host        = each.value.default_ipv4_address
  port        = 22
  user        = "root"
  private_key = var.ssh_private_key

  pre_commands = [<<-EOT
    mkdir -p /etc/rancher/${var.kubernetes_engine}/config.yaml.d
    # mkdir -p /usr/local/bin
    EOT
  ]

  file {
    destination = "/etc/rancher/${var.kubernetes_engine}/config.yaml"
    owner       = "root"
    group       = "root"
    permissions = "0640"
    content     = <<-EOT
node-name: ${each.value.fqdn}
selinux: ${local.selinux_booltext}
kubelet-arg:
  - "node-status-update-frequency=5s"
EOT
  }

  commands = var.kubernetes_engine == "k3s" ? [<<-EOT
    curl -sfL https://get.k3s.io | \
      INSTALL_K3S_VERSION="${var.kubernetes_engine_version}" \
      K3S_URL="${local.cluster_url}" \
      K3S_TOKEN="${local.cluster_token}" \
      INSTALL_K3S_SKIP_START=true \
      INSTALL_K3S_SKIP_SELINUX_RPM=true \
      INSTALL_K3S_SELINUX_WARN=true \
      sh - > /var/log/curl_install_${var.kubernetes_engine}.log 2>&1

    systemctl stop sshd.service && reboot
    EOT
  ] : var.kubernetes_engine == "rke2" ? [<<-EOT
    curl -sfL https://get.rke2.io | \
      INSTALL_RKE2_VERSION="${var.kubernetes_engine_version}" \
      RKE2_URL="${local.cluster_url}" \
      RKE2_TOKEN="${local.cluster_token}" \
      sh - > /var/log/curl_install_${var.kubernetes_engine}.log 2>&1

    systemctl enable rke2-agent.service
    systemctl stop sshd.service && reboot
    EOT
  ] : []
}

