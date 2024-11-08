resource "ssh_resource" "grow_filesystem" {
  for_each     = var.cluster_nodes

  host         = each.value.public_ipv4_address
  #bastion_host = var.bastion_host
  port         = 22
  user         = "root"
  private_key  = var.ssh_private_key

  commands = [
    "btrfs fi resize max /var",
#    "transactional-update --no-selfupdate pkg install -y cri-tools kubernetes-client llvm clang",
#    "systemctl stop sshd.service && reboot"
  ]
}

