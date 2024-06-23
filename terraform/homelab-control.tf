resource "libvirt_volume" "homelab-control_vol" {
  name           = "homelab-control${format("%02d", count.index + var.control_offset)}.qcow2"
  pool           = var.images_pool
  size           = 10240000000 # size is in bytes
  base_volume_id = libvirt_volume.debian_image.id
  count          = var.control_quantity
}

resource "libvirt_cloudinit_disk" "homelab-control_cinit" {
  name      = "homelab-control${format("%02d", count.index + var.control_offset)}-commoninit.iso"
  pool      = var.boot_pool
  meta_data = data.template_file.homelab-control_metadata[count.index].rendered
  user_data = data.template_file.homelab-control_userdata[count.index].rendered
  count     = var.control_quantity
}

data "template_file" "homelab-control_metadata" {
  template = file("../cloud-init/homelab-control/meta-data")
  count    = var.control_quantity
  vars = {
    hostname = "homelab-control${format("%02d", count.index + var.control_offset)}.homelab.home.arpa"
  }
}

data "template_file" "homelab-control_userdata" {
  template = file("../cloud-init/homelab-control/user-data")
  count    = var.control_quantity
  vars = {
    hostname = "homelab-control${format("%02d", count.index + var.control_offset)}.homelab.home.arpa"
    number   = "${format("%02d", count.index + var.control_offset)}"
  }
}

resource "libvirt_domain" "homelab-control" {
  depends_on = [time_sleep.wait_for_homelab-out]
  machine    = "pc-q35-8.1"
  # UEFI firmware
  firmware = "/usr/share/OVMF/OVMF_CODE.fd"
  nvram {
    template = "/usr/share/OVMF/OVMF_VARS.fd"
    # This is the file which will back the UEFI NVRAM content.
    file = "/var/lib/libvirt/qemu/nvram/homelab-control${format("%02d", count.index + var.nodes_offset)}.fd"
  }
  name       = "homelab-control${format("%02d", count.index + var.control_offset)}"
  memory     = "2048"
  vcpu       = "2"
  cpu {
    mode = "host-passthrough"
  }
  cloudinit = libvirt_cloudinit_disk.homelab-control_cinit[count.index].id

  # eth0
  network_interface {
    network_name   = "homelab-main"
    hostname       = "homelab-control${format("%02d", count.index + var.control_offset)}.homelab.home.arpa"
    wait_for_lease = true
    mac            = "52:54:00:7e:8a:${format("%02x", count.index + var.control_offset)}"
    addresses      = ["10.99.99.${format("%02d", count.index + var.control_offset)}"]
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
    volume_id = libvirt_volume.homelab-control_vol[count.index].id
  }
  xml {
    xslt = file("sata-cloudinit.xsl")
  }
  count = var.control_quantity
}
