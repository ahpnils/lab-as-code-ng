resource "libvirt_volume" "homelab-worker_vol" {
  name           = "homelab-worker${format("%02d", count.index + var.worker_offset)}.qcow2"
  pool           = var.images_pool
  size           = 10240000000 # size is in bytes
  base_volume_id = libvirt_volume.debian_image.id
  count          = var.worker_quantity
}

resource "libvirt_cloudinit_disk" "homelab-worker_cinit" {
  name      = "homelab-worker${format("%02d", count.index + var.worker_offset)}-commoninit.iso"
  pool      = var.boot_pool
  meta_data = data.template_file.homelab-worker_metadata[count.index].rendered
  user_data = data.template_file.homelab-worker_userdata[count.index].rendered
  count     = var.worker_quantity
}

data "template_file" "homelab-worker_metadata" {
  template = file("../cloud-init/homelab-worker/meta-data")
  count    = var.worker_quantity
  vars = {
    hostname = "homelab-worker${format("%02d", count.index + var.worker_offset)}.homelab.home.arpa"
  }
}

data "template_file" "homelab-worker_userdata" {
  template = file("../cloud-init/homelab-worker/user-data")
  count    = var.worker_quantity
  vars = {
    hostname = "homelab-worker${format("%02d", count.index + var.worker_offset)}.homelab.home.arpa"
    number   = "${format("%02d", count.index + var.worker_offset)}"
  }
}

resource "libvirt_domain" "homelab-worker" {
  depends_on = [time_sleep.wait_for_homelab-out]
  machine    = "pc-q35-8.1"
  # UEFI firmware
  firmware = "/usr/share/OVMF/OVMF_CODE.fd"
  nvram {
    template = "/usr/share/OVMF/OVMF_VARS.fd"
    # This is the file which will back the UEFI NVRAM content.
    file = "/var/lib/libvirt/qemu/nvram/homelab-worker${format("%02d", count.index + var.nodes_offset)}.fd"
  }
  name       = "homelab-worker${format("%02d", count.index + var.worker_offset)}"
  memory     = "4096"
  vcpu       = "2"
  cpu {
    mode = "host-passthrough"
  }
  cloudinit = libvirt_cloudinit_disk.homelab-worker_cinit[count.index].id

  # eth0
  network_interface {
    network_name   = "homelab-main"
    hostname       = "homelab-worker${format("%02d", count.index + var.worker_offset)}.homelab.home.arpa"
    wait_for_lease = true
    mac            = "52:54:00:7e:8a:${format("%02x", count.index + var.worker_offset)}"
    addresses      = ["10.99.99.${format("%02d", count.index + var.worker_offset)}"]
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
    volume_id = libvirt_volume.homelab-worker_vol[count.index].id
  }
  xml {
    xslt = file("sata-cloudinit.xsl")
  }
  count = var.worker_quantity
}
