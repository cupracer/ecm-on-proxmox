locals {
  name = var.name
  microos_snapshot_id = var.microos_snapshot_id
  server_type        = var.server_type
  location           = var.location
  ssh_keys           = var.ssh_keys
#  firewall_ids       = var.firewall_ids
#  placement_group_id = var.placement_group_id
#  backups            = var.backups
  user_data          = data.cloudinit_config.user_data.rendered
#  keep_disk          = var.keep_disk_size
#  labels = var.labels
  root_public_keys             = var.root_public_keys
  ci_root_lock_password        = var.ci_root_lock_password
  ci_root_plain_password       = var.ci_root_plain_password
}

data "cloudinit_config" "user_data" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"

    content = templatefile("${path.module}/ci_user_data.yaml.tftpl", {
      hostname = local.name,
      root_public_keys = local.root_public_keys,
      root_lock_password = local.ci_root_lock_password,
      root_plain_password = local.ci_root_plain_password
    })
  }
}


resource "hcloud_server" "server" {
  name               = local.name
  image              = local.microos_snapshot_id
  server_type        = local.server_type
  location           = local.location
  ssh_keys           = local.ssh_keys
#  firewall_ids       = var.firewall_ids
#  placement_group_id = var.placement_group_id
#  backups            = var.backups
  user_data          = data.cloudinit_config.user_data.rendered
#  keep_disk          = var.keep_disk_size

#  labels = var.labels

  # Prevent destroying the whole cluster if the user changes
  # any of the attributes that force to recreate the servers.
#  lifecycle {
#    ignore_changes = [
#      location,
#      ssh_keys,
#      user_data,
#      image,
#    ]
#  }
}

