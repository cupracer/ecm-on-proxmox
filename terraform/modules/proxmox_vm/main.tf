locals {
  proxmox_node                 = var.proxmox_node
  name                         = var.name
  description                  = var.description
  template                     = var.template
  cpu_cores                    = var.cpu_cores
  memory                       = var.memory
  disk_size                    = var.disk_size
  storage_pool                 = var.storage_pool
  iso_storage_pool             = var.iso_storage_pool
  network_bridge               = var.network_bridge
  root_public_keys             = var.root_public_keys
  ci_root_lock_password        = var.ci_root_lock_password
  ci_root_plain_password       = var.ci_root_plain_password
}

resource "proxmox_cloud_init_disk" "ci" {
  name      = local.name
  pve_node  = local.proxmox_node
  storage   = local.iso_storage_pool

  meta_data = yamlencode({
    instance_id    = sha1(local.name)
    local-hostname = local.name
  })

  user_data = templatefile("${path.module}/ci_user_data.yaml.tftpl", {
    root_public_keys = local.root_public_keys,
    root_lock_password = local.ci_root_lock_password,
    root_plain_password = local.ci_root_plain_password
  })

#  network_config = yamlencode({
#    version = 1
#    config  = [{
#      type    = "physical"
#      name    = "eth0"
#      subnets = [{
#        type = "dhcp"
#      }]
#    }]
#  })
}

resource "proxmox_vm_qemu" "vm" {
  name        = local.name
  desc        = local.description
  target_node = local.proxmox_node
  clone       = local.template
  full_clone  = false

  bios    = "ovmf"
  sockets = 1
  cores   = local.cpu_cores
  memory  = local.memory
  scsihw  = "virtio-scsi-single"
  qemu_os = "l26"
  agent   = 1

  disks {
    scsi {
      scsi0 {
        disk {
          storage = local.storage_pool
          size    = local.disk_size
          discard = true
          emulatessd = true
        }
      }
      scsi1 {
        cdrom {
          iso  = proxmox_cloud_init_disk.ci.id
        }
      }
    }
  }

  network {
    bridge = local.network_bridge
    model  = "virtio"
  }

  lifecycle {
    ignore_changes = [
      network,
    ]
  }
}

