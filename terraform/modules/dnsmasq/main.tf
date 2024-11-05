resource "ssh_resource" "dnsserver_prepare" {
  for_each     = var.proxy_nodes

  host         = each.value.public_ipv4_address
  #bastion_host = var.bastion_host
  port         = 22
  user         = "root"
  private_key  = var.ssh_private_key

  commands = [<<-EOT
    transactional-update --no-selfupdate shell <<< "
      zypper --gpg-auto-import-keys install -y dnsmasq"
    systemctl stop sshd.service && reboot
    EOT
  ]
}

resource "ssh_resource" "dnsserver" {
  depends_on = [ ssh_resource.dnsserver_prepare ]

  for_each     = var.proxy_nodes

  host         = each.value.public_ipv4_address
  #bastion_host = var.bastion_host
  port         = 22
  user         = "root"
  private_key  = var.ssh_private_key

  pre_commands = [<<-EOT
    mkdir -p /etc/dnsmasq.hosts.d
    EOT
  ]

  file {
    destination = "/etc/dnsmasq.conf"
    owner = "root"
    group = "root"
    permissions = "0644"
    content = templatefile("${path.module}/dnsmasq.conf.tftpl", {
      parent_dns = var.parent_dns
    })
  }

#  file {
#    destination = "/etc/dnsmasq.hosts.d/${each.value.name}.conf"
#    owner = "root"
#    group = "root"
#    permissions = "0644"
#    content = templatefile("${path.module}/dnsmasq.hosts.tftpl", {
#      dns_entries = [{
#          ip_address = each.value.default_ipv4_address
#          fqdn = each.value.fqdn
#        }]
#    })
#  }

  commands = [<<-EOT
    touch /etc/dnsmasq.hosts
    systemctl enable dnsmasq.service
    systemctl restart dnsmasq.service
    EOT
  ]
}

