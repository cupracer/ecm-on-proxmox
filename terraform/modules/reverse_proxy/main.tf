resource "ssh_resource" "install_podman" {
  for_each     = var.nodes

  host         = each.value.default_ipv4_address
  port         = 22
  user         = "root"
  private_key  = var.ssh_private_key

  commands = [
    "transactional-update --no-selfupdate shell <<< 'zypper --non-interactive install podman && setsebool -P container_manage_cgroup on'",
    "systemctl stop sshd.service && reboot",
  ]
}

resource "ssh_resource" "setup_podman_nginx" {
  depends_on   = [ ssh_resource.install_podman ]

  for_each     = var.nodes

  host         = each.value.default_ipv4_address
  port         = 22
  user         = "root"
  private_key  = var.ssh_private_key

  # TODO: REMOVE /bin/true WORKAROUND; HOW TO DETECT IF THIS IS A FIRST RUN?
  pre_commands = [
    "systemctl disable podman-nginx; /bin/true",
  ]

  file {
    destination = "/etc/systemd/system/podman-nginx.service"
    owner = "root"
    group = "root"
    permissions = "0644"
    content = <<-EOT
      [Unit]
      Description=Nginx container
      After=network-online.target

      [Service]
      Type=exec
      ExecStart=/usr/bin/podman run --rm -a stdout --name podman-nginx -p 80:80 -p 443:443 -p 6443:6443 -v /etc/nginx.conf:/etc/nginx/nginx.conf:ro registry.suse.com/suse/nginx
      ExecStop=/usr/bin/sh -c 'while kill $MAINPID 2>/dev/null; do sleep 1; done'
      TimeoutStopSec=20

      [Install]
      WantedBy=default.target
    EOT
  }  

  commands = [
    "systemctl daemon-reload",
    "systemctl enable podman-nginx",
  ]
}

resource "ssh_resource" "setup_nginx_config" {
  depends_on   = [ ssh_resource.setup_podman_nginx, ]

  for_each     = var.nodes

  host         = each.value.default_ipv4_address
  port         = 22
  user         = "root"
  private_key  = var.ssh_private_key

  file {
    destination = "/etc/nginx.conf"
    owner = "root"
    group = "root"
    permissions = "0644"
    content = templatefile("${path.module}/nginx.conf.tftpl", {
      node_control_planes_fqdn = var.control_planes_fqdn
    })
  }

  commands = [
    "systemctl restart podman-nginx",
  ]
}

