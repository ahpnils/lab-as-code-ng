resource "libvirt_volume" "homelab-arch_vol" {
  name           = "homelab-arch${format("%02d", count.index)}.qcow2"
  pool           = var.images_pool
  size           = var.arch_system_disk_size
  base_volume_id = libvirt_volume.arch_image.id
  count          = var.arch_quantity
}

resource "libvirt_cloudinit_disk" "homelab-arch_cinit" {
  name      = "homelab-arch${format("%02d", count.index)}-commoninit.iso"
  pool      = var.boot_pool
  meta_data = data.template_file.homelab-arch_metadata[count.index].rendered
  user_data = data.template_file.homelab-arch_userdata[count.index].rendered
  count     = var.arch_quantity
}

data "template_file" "homelab-arch_metadata" {
  template = file("../cloud-init/homelab-arch/meta-data")
  count    = var.arch_quantity
  vars = {
    hostname = "homelab-arch${format("%02d", count.index)}.homelab.home.arpa"
  }
}

data "template_file" "homelab-arch_userdata" {
  template = file("../cloud-init/homelab-arch/user-data")
  count    = var.arch_quantity
  vars = {
    hostname = "homelab-arch${format("%02d", count.index)}.homelab.home.arpa"
    number   = "${format("%02d", count.index)}"
  }
}

resource "libvirt_domain" "homelab-arch" {
  depends_on = [time_sleep.wait_for_homelab-out]
  machine    = "pc-q35-8.1"
  # UEFI firmware
  firmware = "/usr/share/OVMF/OVMF_CODE.fd"
  nvram {
    template = "/usr/share/OVMF/OVMF_VARS.fd"
    # This is the file which will back the UEFI NVRAM content.
    file = "/var/lib/libvirt/qemu/nvram/homelab-arch${format("%02d", count.index)}.fd"
  }
  name   = "homelab-arch${format("%02d", count.index)}"
  memory = var.arch_memory
  vcpu   = var.arch_vcpu
  cpu {
    mode = "host-passthrough"
  }
  cloudinit = libvirt_cloudinit_disk.homelab-arch_cinit[count.index].id

  # eth0
  network_interface {
    network_name   = "homelab-main"
    hostname       = "homelab-arch${format("%02d", count.index)}.homelab.home.arpa"
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

  disk {
    volume_id = libvirt_volume.homelab-arch_vol[count.index].id
  }
  xml {
    xslt = file("sata-cloudinit.xsl")
  }
  count = var.arch_quantity
}
