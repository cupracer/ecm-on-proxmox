packer {
  required_plugins {
    name = {
      version = "~> 1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox-iso" "microos" {
  proxmox_url = var.proxmox_url
  node        = var.proxmox_node
  username    = var.proxmox_username
  token       = var.proxmox_token

  template_name        = "opensuse-microos"
  template_description = "openSUSE MicroOS, generated on ${timestamp()}"
  unmount_iso          = true

  os              = "l26"
  bios            = "ovmf"
  cores           = var.cpu_cores
  memory          = var.memory
  scsi_controller = "virtio-scsi-single"

  boot_command = ["<home>", "<down>", "<enter>", "<wait20>", "<enter>", ]
  boot_wait    = "10s"

  #  cloud_init            = true
  #  cloud_init_storage_pool = var.storage_pool

  disks {
    disk_size    = var.disk_size
    storage_pool = var.storage_pool
    type         = "scsi"
    discard      = true
    ssd          = true
  }

  efi_config {
    efi_storage_pool  = var.storage_pool
    efi_type          = "4m"
    pre_enrolled_keys = true
  }

  iso_file     = var.iso_file
  iso_checksum = var.iso_checksum

  network_adapters {
    bridge = var.network_bridge
    model  = "virtio"
  }

  ssh_username         = "root"
  ssh_private_key_file = "../ssh_files/packer"
  # ssh_timeout          = "20m"

  additional_iso_files {
    # IMPORTANT - MacOS users: Install xorriso (eg. via Homebrew) to ensure that
    # the generated ISO file can be detected by Ignition / Combustion.

    unmount          = true
    iso_storage_pool = var.iso_storage_pool
    cd_files         = ["./combustion"]
    cd_label         = "combustion"
  }
}

build {
  sources = ["source.proxmox-iso.microos"]

  provisioner "shell" {
    inline = [
      "echo 'Remove authorized_keys' && rm -vf /root/.ssh/authorized_keys"
    ]
  }
}

