resource "ssh_resource" "setup_podman_nginx" {
  for_each     = var.nodes

  host         = each.value.default_ipv4_address
  port         = 22
  user         = "root"
  private_key  = var.ssh_private_key

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
      ExecStart=/usr/bin/podman run --rm -a stdout --name podman-nginx -p 80:80 -p 443:443 -p 8080:8080 docker.io/library/nginx
      ExecStop=/usr/bin/sh -c 'while kill $MAINPID 2>/dev/null; do sleep 1; done'
      TimeoutStopSec=20

      [Install]
      WantedBy=default.target
    EOT
  }  

  commands = [
    "systemctl daemon-reload",
    "systemctl enable podman-nginx",
    "transactional-update --no-selfupdate shell <<< 'zypper --non-interactive install podman && setsebool -P container_manage_cgroup on'",
    "systemctl stop sshd.service && reboot",
  ]
}

