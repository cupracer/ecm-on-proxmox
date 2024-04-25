locals {
  dnsmasq_hosts = length(var.dnsmasq_hosts) > 0 ? {
    for host in var.dnsmasq_hosts :
      host => { default_ipv4_address = host }
  } : {}

  dns_entries = {
    for node in merge(var.proxy_nodes, var.cluster_nodes) :
      node.default_ipv4_address => node.fqdn
  }
}

resource "ssh_resource" "dnsmasq_hosts" {
  for_each     = length(local.dnsmasq_hosts) > 0 ? local.dnsmasq_hosts : var.proxy_nodes

  host         = each.value.default_ipv4_address
  port         = 22
  user         = "root"
  private_key  = var.ssh_private_key

  file {
    destination = "/etc/dnsmasq.hosts.d/${var.cluster_name}.conf"
    owner = "root"
    group = "root"
    permissions = "0644"
    content = templatefile("${path.module}/dnsmasq.hosts.tftpl", {
      dns_entries = concat(
        [
          for ip, fqdn in local.dns_entries : {
            ip_address = ip
            fqdn = fqdn
          }
        ]
      )
    })
  }

#  commands = [<<-EOT
#    systemctl restart dnsmasq.service
#    EOT
#  ]

  commands = [<<-EOT
    systemctl stop sshd.service && reboot
    EOT
  ]
}

