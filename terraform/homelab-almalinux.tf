resource "libvirt_volume" "homelab-almalinux_vol" {
  name           = "homelab-almalinux${format("%02d", count.index)}.qcow2"
  pool           = var.images_pool
  size           = var.almalinux_system_disk_size
  base_volume_id = libvirt_volume.almalinux_image.id
  count          = var.almalinux_quantity
}

resource "libvirt_cloudinit_disk" "homelab-almalinux_cinit" {
  name      = "homelab-almalinux${format("%02d", count.index)}-commoninit.iso"
  pool      = var.boot_pool
  meta_data = data.template_file.homelab-almalinux_metadata[count.index].rendered
  user_data = data.template_file.homelab-almalinux_userdata[count.index].rendered
  count     = var.almalinux_quantity
}

data "template_file" "homelab-almalinux_metadata" {
  template = file("../cloud-init/homelab-almalinux/meta-data")
  count    = var.almalinux_quantity
  vars = {
    hostname = "homelab-almalinux${format("%02d", count.index)}.homelab.home.arpa"
  }
}

data "template_file" "homelab-almalinux_userdata" {
  template = file("../cloud-init/homelab-almalinux/user-data")
  count    = var.almalinux_quantity
  vars = {
    hostname = "homelab-almalinux${format("%02d", count.index)}.homelab.home.arpa"
  }
}

resource "libvirt_domain" "homelab-almalinux" {
  depends_on = [time_sleep.wait_for_homelab-out]
  machine    = "pc-q35-8.1"
  # UEFI firmware
  nvram {
    template = "/usr/share/OVMF/OVMF_VARS.fd"
    # This is the file which will back the UEFI NVRAM content.
    file = "/var/lib/libvirt/qemu/nvram/homelab-almalinux${format("%02d", count.index)}.fd"
  }
  name   = "homelab-almalinux${format("%02d", count.index)}"
  memory = var.almalinux_memory
  vcpu   = var.almalinux_vcpu
  cpu {
    mode = "host-passthrough"
  }
  cloudinit  = libvirt_cloudinit_disk.homelab-almalinux_cinit[count.index].id
  qemu_agent = true

  # eth0
  network_interface {
    network_name   = "homelab-main"
    hostname       = "homelab-almalinux${format("%02d", count.index)}.homelab.home.arpa"
    wait_for_lease = true
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_port = "1"
    target_type = "virtio"
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
    volume_id = libvirt_volume.homelab-almalinux_vol[count.index].id
  }
  xml {
    xslt = file("sata-cloudinit.xsl")
  }
  count = var.almalinux_quantity
}
