resource "ssh_resource" "system_settings" {
  for_each     = var.cluster_nodes

  host         = each.value.public_ipv4_address
  #bastion_host = var.bastion_host
  port         = 22
  user         = "root"
  private_key  = var.ssh_private_key

  commands = [
    "btrfs fi resize max /var",
    "ln -fs /usr/share/zoneinfo/Europe/Berlin /etc/localtime",
  ]
}

resource "ssh_resource" "install_packages" {
  for_each     = var.cluster_nodes

  host         = each.value.public_ipv4_address
  #bastion_host = var.bastion_host
  port         = 22
  user         = "root"
  private_key  = var.ssh_private_key

  commands = [<<-EOT
    transactional-update --no-selfupdate pkg install --recommends -y \
      cri-tools kubernetes-client llvm clang \
      iptables bind-utils mtr tcpdump wireguard-tools \
      restorecond setools-console \
      open-iscsi nfs-client cifs-utils \
      bash-completion git cryptsetup \
      command-not-found policycoreutils-python-utils
    systemctl stop sshd.service && reboot
  EOT
  ]
}
