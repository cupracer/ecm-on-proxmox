locals {
  cluster_token     = random_string.cluster_token.result
  random_proxy_node = values(var.proxy_nodes)[0]  #TODO: THIS IS FAKE AND NEEDS TO BE FIXED (NO RANDOM NEEDED)
  cluster_url       = "https://${local.random_proxy_node.fqdn}:6443"
}

resource "random_string" "cluster_token" {
  length  = 64
  upper   = true
  special = false
}

resource "ssh_resource" "workaround_disable_selinux" {
  for_each     = merge(var.control_plane_nodes, var.worker_nodes)

  host         = each.value.default_ipv4_address
  port         = 22
  user         = "root"
  private_key  = var.ssh_private_key

  commands = [
    "sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT/s/ selinux=./ selinux=0/' /etc/default/grub",
    "transactional-update --no-selfupdate grub.cfg",
    "systemctl stop sshd.service && reboot",
  ]
}

resource "ssh_resource" "setup_control_planes" {
  depends_on = [ ssh_resource.workaround_disable_selinux ]

  for_each = var.control_plane_nodes

  host         = each.value.default_ipv4_address
  port         = 22
  user         = "root"
  private_key  = var.ssh_private_key

  pre_commands = [
    "mkdir -p /etc/rancher/k3s/config.yaml.d",
    "mkdir -p /var/lib/rancher/k3s/server/manifests",
  ]

  file {
    destination = "/etc/rancher/k3s/config.yaml"
    owner = "root"
    group = "root"
    permissions = "0640"
    content = templatefile("${path.module}/control_plane_config.yaml.tftpl", {
      fqdn              = each.value.fqdn
      cluster_token     = local.cluster_token
      cluster_fqdn      = var.cluster_fqdn
      proxy_fqdns       = [for node in var.proxy_nodes : node.fqdn]
      proxy_ipv4s       = [for node in var.proxy_nodes : node.default_ipv4_address]
      disable_servicelb = var.disable_k3s_servicelb
      disable_traefik   = var.disable_k3s_traefik
      set_taints        = var.set_taints
    })
  }

  # TODO: DON'T USE A RANDOM PROXY NODE; USE AN LB FQDN INSTEAD
  file {
    destination = "/etc/rancher/k3s/config.yaml.d/server.yaml"
    owner = "root"
    group = "root"
    permissions = "0640"
    content = each.value.fqdn == var.primary_master_fqdn ? (<<-EOT
cluster-init: true
EOT
      ) : <<-EOT
server: ${local.cluster_url}
EOT
  }

  commands = [<<-EOT
    curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="${var.k3s_version}" INSTALL_K3S_SKIP_START=true INSTALL_K3S_SKIP_SELINUX_RPM=true INSTALL_K3S_SELINUX_WARN=true sh -s - server > /var/log/curl_install_k3s.log 2>&1

    transactional-update --no-selfupdate --continue shell <<< "
      zypper --gpg-auto-import-keys install -y cri-tools kubernetes-client llvm clang"

    mkdir -p /root/.kube
    ln -sf /etc/rancher/k3s/k3s.yaml /root/.kube/config
    systemctl stop sshd.service && reboot
    EOT
  ]
}


resource "ssh_resource" "retrieve_cluster_config" {
  depends_on = [ ssh_resource.setup_control_planes ]

  host         = var.primary_master_host
  port         = 22
  user         = "root"
  private_key  = var.ssh_private_key

  # TODO: DEFINE A CLUSTER FQDN INSTEAD OF POINTING TO A SINGLE PROXY DIRECTLY
  commands = [
    "sudo sed \"s/127.0.0.1/${local.random_proxy_node.fqdn}/g\" /etc/rancher/k3s/k3s.yaml"
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

resource "null_resource" "wait_for_k3s" {
  triggers = {
    url_check = data.http.k3s.request_body == "pong"
  }

  provisioner "local-exec" {
    command = "echo 'URL is successful.'"
  }
}

data "http" "k3s" {
  depends_on = [ local_file.kube_config_server_yaml, ]

  url = "${local.cluster_url}/ping"
  insecure = true
}

resource "ssh_resource" "setup_workers" {
  depends_on = [ null_resource.wait_for_k3s, ]

  for_each = var.worker_nodes

  host         = each.value.default_ipv4_address
  port         = 22
  user         = "root"
  private_key  = var.ssh_private_key

  pre_commands = [<<-EOT
    mkdir -p /etc/rancher/k3s/config.yaml.d
    # mkdir -p /usr/local/bin
    EOT
  ]

  file {
    destination = "/etc/rancher/k3s/config.yaml"
    owner = "root"
    group = "root"
    permissions = "0640"
    content = <<-EOT
# Only works in K3S_URL variable => server: ${local.cluster_url}
# Only works in K3S_TOKEN variable => token: ${local.cluster_token}
selinux: true
kubelet-arg:
  - "node-status-update-frequency=5s"
EOT
  }

  commands = [<<-EOT
    curl -sfL https://get.k3s.io | \
      INSTALL_K3S_VERSION="${var.k3s_version}" \
      K3S_URL="${local.cluster_url}" \
      K3S_TOKEN="${local.cluster_token}" \
      INSTALL_K3S_SKIP_START=true \
      INSTALL_K3S_SKIP_SELINUX_RPM=true \
      INSTALL_K3S_SELINUX_WARN=true \
      sh - > /var/log/curl_install_k3s.log 2>&1

    transactional-update --no-selfupdate --continue shell <<< "
      zypper --gpg-auto-import-keys install -y cri-tools llvm clang"

    systemctl stop sshd.service && reboot
    EOT
  ]
}

