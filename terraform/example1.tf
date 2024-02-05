locals {
  proxmox_node                    = var.proxmox_node
  vm_name                         = "example1"
  vm_description                  = "openSUSE MicroOS"
  vm_template                     = "opensuse-microos"
  vm_cpu_sockets                  = 1
  vm_cpu_cores                    = 2
  vm_memory                       = 2048
  vm_disk_size                    = 20
  vm_storage_pool                 = var.storage_pool
  vm_iso_storage_pool             = var.iso_storage_pool
  vm_network_bridge               = var.network_bridge
  vm_ci_root_authorized_keys_file = var.ci_root_authorized_keys_file
  vm_ci_root_lock_password        = var.ci_root_lock_password
  vm_ci_root_plain_password       = var.ci_root_plain_password
}

resource "proxmox_cloud_init_disk" "ci" {
  name      = local.vm_name
  pve_node  = local.proxmox_node
  storage   = local.vm_iso_storage_pool

  meta_data = yamlencode({
    instance_id    = sha1(local.vm_name)
    local-hostname = local.vm_name
  })

  user_data = templatefile("ci_user_data.yaml.tftpl", {
    root_public_keys = [ for key in try(split("\n", file(local.vm_ci_root_authorized_keys_file)), []) : key if key != "" ],
    root_lock_password = local.vm_ci_root_lock_password,
    root_plain_password = local.vm_ci_root_plain_password
  })

  network_config = yamlencode({
    version = 1
    config  = [{
      type    = "physical"
      name    = "eth0"
      subnets = [{
        type = "dhcp"
      }]
    }]
  })
}

resource "proxmox_vm_qemu" "vm" {
  name        = local.vm_name
  desc        = local.vm_description
  target_node = local.proxmox_node
  clone       = local.vm_template

  bios    = "ovmf"
  sockets = local.vm_cpu_sockets
  cores   = local.vm_cpu_cores
  memory  = local.vm_memory
  scsihw  = "virtio-scsi-single"
  os_type = "l26"
  agent   = 1

  # vga {
  #   type = "std"
  # }

  disks {
    scsi {
      scsi0 {
        disk {
          storage = local.vm_storage_pool
          size    = local.vm_disk_size
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
    bridge = local.vm_network_bridge
    model  = "virtio"
  }
}

output "default_ipv4_address" {
  value = proxmox_vm_qemu.vm.default_ipv4_address
}

