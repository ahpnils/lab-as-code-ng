resource "libvirt_volume" "homelab-dragonflybsd_vol" {
  name           = "homelab-dragonflybsd${format("%02d", count.index)}.qcow2"
  pool           = var.images_pool
  size           = var.dragonflybsd_system_disk_size
  base_volume_id = libvirt_volume.dragonflybsd_image.id
  count          = var.dragonflybsd_quantity
}

resource "libvirt_cloudinit_disk" "homelab-dragonflybsd_cinit" {
  name      = "homelab-dragonflybsd${format("%02d", count.index)}-commoninit.iso"
  pool      = var.boot_pool
  meta_data = data.template_file.homelab-dragonflybsd_metadata[count.index].rendered
  user_data = data.template_file.homelab-dragonflybsd_userdata[count.index].rendered
  count     = var.dragonflybsd_quantity
}

data "template_file" "homelab-dragonflybsd_metadata" {
  template = file("../cloud-init/homelab-dragonflybsd/meta-data")
  count    = var.dragonflybsd_quantity
  vars = {
    hostname = "homelab-dragonflybsd${format("%02d", count.index)}.homelab.home.arpa"
  }
}

data "template_file" "homelab-dragonflybsd_userdata" {
  template = file("../cloud-init/homelab-dragonflybsd/user-data")
  count    = var.dragonflybsd_quantity
  vars = {
    hostname = "homelab-dragonflybsd${format("%02d", count.index)}.homelab.home.arpa"
    number   = "${format("%02d", count.index)}"
  }
}

resource "libvirt_domain" "homelab-dragonflybsd" {
  depends_on = [time_sleep.wait_for_homelab-out]
  #machine    = "pc-q35-8.1"
  machine = "pc-i440fx-8.2"
  # UEFI firmware
  firmware = "/usr/share/OVMF/OVMF_CODE.fd"
  nvram {
    template = "/usr/share/OVMF/OVMF_VARS.fd"
    # This is the file which will back the UEFI NVRAM content.
    file = "/var/lib/libvirt/qemu/nvram/homelab-dragonflybsd${format("%02d", count.index)}.fd"
  }
  name   = "homelab-dragonflybsd${format("%02d", count.index)}"
  memory = var.dragonflybsd_memory
  vcpu   = var.dragonflybsd_vcpu
  cpu {
    mode = "host-passthrough"
  }
  cloudinit = libvirt_cloudinit_disk.homelab-dragonflybsd_cinit[count.index].id

  # eth0
  network_interface {
    network_name   = "homelab-main"
    hostname       = "homelab-dragonflybsd${format("%02d", count.index)}.homelab.home.arpa"
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
    volume_id = libvirt_volume.homelab-dragonflybsd_vol[count.index].id
  }
  xml {
    xslt = file("sata-cloudinit.xsl")
  }
  count = var.dragonflybsd_quantity
}
