resource "libvirt_volume" "homelab-rockylinux_vol" {
  name           = "homelab-rockylinux${format("%02d", count.index)}.qcow2"
  pool           = var.images_pool
  size           = var.rockylinux_system_disk_size
  base_volume_id = libvirt_volume.rockylinux_image.id
  count          = var.rockylinux_quantity
}

resource "libvirt_cloudinit_disk" "homelab-rockylinux_cinit" {
  name      = "homelab-rockylinux${format("%02d", count.index)}-commoninit.iso"
  pool      = var.boot_pool
  meta_data = data.template_file.homelab-rockylinux_metadata[count.index].rendered
  user_data = data.template_file.homelab-rockylinux_userdata[count.index].rendered
  count     = var.rockylinux_quantity
}

data "template_file" "homelab-rockylinux_metadata" {
  template = file("../cloud-init/homelab-rockylinux/meta-data")
  count    = var.rockylinux_quantity
  vars = {
    hostname = "homelab-rockylinux${format("%02d", count.index)}.homelab.home.arpa"
  }
}

data "template_file" "homelab-rockylinux_userdata" {
  template = file("../cloud-init/homelab-rockylinux/user-data")
  count    = var.rockylinux_quantity
  vars = {
    hostname      = "homelab-rockylinux${format("%02d", count.index)}.homelab.home.arpa"
    ssh_pubkey    = var.ssh_pubkey
    user_name     = var.user_name
    user_password = var.user_password
  }
}

resource "libvirt_domain" "homelab-rockylinux" {
  depends_on = [time_sleep.wait_for_homelab-out]
  machine    = "pc-q35-8.1"
  # UEFI firmware
  nvram {
    template = "/usr/share/OVMF/OVMF_VARS.fd"
    # This is the file which will back the UEFI NVRAM content.
    file = "/var/lib/libvirt/qemu/nvram/homelab-rockylinux${format("%02d", count.index)}.fd"
  }
  name   = "homelab-rockylinux${format("%02d", count.index)}"
  memory = var.rockylinux_memory
  vcpu   = var.rockylinux_vcpu
  cpu {
    mode = "host-passthrough"
  }
  cloudinit  = libvirt_cloudinit_disk.homelab-rockylinux_cinit[count.index].id
  qemu_agent = true

  # eth0
  network_interface {
    network_name   = "homelab-main"
    hostname       = "homelab-rockylinux${format("%02d", count.index)}.homelab.home.arpa"
    wait_for_lease = true
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }

  video {
    type = "virtio"
  }

  disk {
    volume_id = libvirt_volume.homelab-rockylinux_vol[count.index].id
  }
  xml {
    xslt = file("sata-cloudinit.xsl")
  }
  count = var.rockylinux_quantity
}
