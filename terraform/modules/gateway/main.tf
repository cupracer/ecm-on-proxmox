resource "ssh_resource" "be_gateway" {
  for_each     = var.nodes

  host         = each.value.public_ipv4_address
  #bastion_host = var.bastion_host
  port         = 22
  user         = "root"
  private_key  = var.ssh_private_key

  file {
    destination = "/etc/sysctl.d/99-ip_forward.conf"
    owner = "root"
    group = "root"
    permissions = "0644"
    content = <<-EOT
      net.ipv4.ip_forward = 1
      net.ipv6.conf.all.forwarding = 1
      EOT
  }

  # TODO: Wieso ist --continue nötig? Oder sollte ich das besser überall setzen?
  commands = [<<-EOT
    transactional-update --no-selfupdate --continue shell <<< "
      zypper --non-interactive install firewalld firewalld-bash-completion ethtool &&
      systemctl enable firewalld.service"
    systemctl stop sshd.service && reboot
    EOT
  ]
}

resource "ssh_resource" "be_gateway_post" {
  depends_on = [ssh_resource.be_gateway]

  for_each     = var.nodes

  host         = each.value.public_ipv4_address
  #bastion_host = var.bastion_host
  port         = 22
  user         = "root"
  private_key  = var.ssh_private_key

  commands = [<<-EOT
    firewall-cmd --permanent --zone=trusted --change-zone=eth1
    firewall-cmd --permanent --zone=public --add-masquerade

    firewall-cmd --reload
    EOT
  ]
}

