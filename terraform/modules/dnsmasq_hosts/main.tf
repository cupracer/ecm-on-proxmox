locals {
  dnsmasq_servers = length(var.dnsmasq_servers) > 0 ? {
    for host in var.dnsmasq_servers :
      host => { default_ipv4_address = host }
  } : {}

  dns_entries = {
    for node in merge(var.proxy_nodes, var.cluster_nodes) :
      node.default_ipv4_address => node.fqdn
  }

  proxy_ips = [
    for node in var.proxy_nodes :
      node.default_ipv4_address   
  ]
}

resource "ssh_resource" "dnsmasq_hosts" {
  for_each     = length(local.dnsmasq_servers) > 0 ? local.dnsmasq_servers : var.proxy_nodes

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

resource "ssh_resource" "nm_settings" {
  depends_on = [ ssh_resource.dnsmasq_hosts, ]

  for_each = merge(var.proxy_nodes, var.cluster_nodes)

  host         = each.value.default_ipv4_address
  port         = 22
  user         = "root"
  private_key  = var.ssh_private_key

  commands = [<<-EOT
    export NMDEVICE="$(nmcli d show eth0 | grep 'GENERAL.CONNECTION' | awk '{for (i=2; i<=NF; i++) printf "%s ", $i; print ""}' | awk '$1=$1')"
    nmcli con mod "$NMDEVICE" ipv4.ignore-auto-dns yes
    nmcli con mod "$NMDEVICE" ipv6.ignore-auto-dns yes

    for ip in ${join(" ", local.proxy_ips)}; do
      nmcli con mod "$NMDEVICE" ipv4.dns "$ip"
    done

    nmcli con mod "$NMDEVICE" ipv4.dns-search ${var.dnsdomain}
    nohup bash -c 'nmcli con down "$NMDEVICE" && nmcli con up "$NMDEVICE"' &
    EOT
  ]
}

