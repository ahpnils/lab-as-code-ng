resource "libvirt_volume" "homelab-stream_vol" {
  name           = "homelab-stream${format("%02d", count.index)}.qcow2"
  pool           = var.images_pool
  size           = var.stream_system_disk_size
  base_volume_id = libvirt_volume.stream_image.id
  count          = var.stream_quantity
}

resource "libvirt_cloudinit_disk" "homelab-stream_cinit" {
  name      = "homelab-stream${format("%02d", count.index)}-commoninit.iso"
  pool      = var.boot_pool
  meta_data = data.template_file.homelab-stream_metadata[count.index].rendered
  user_data = data.template_file.homelab-stream_userdata[count.index].rendered
  count     = var.stream_quantity
}

data "template_file" "homelab-stream_metadata" {
  template = file("../cloud-init/homelab-stream/meta-data")
  count    = var.stream_quantity
  vars = {
    hostname = "homelab-stream${format("%02d", count.index)}.homelab.home.arpa"
  }
}

data "template_file" "homelab-stream_userdata" {
  template = file("../cloud-init/homelab-stream/user-data")
  count    = var.stream_quantity
  vars = {
    hostname = "homelab-stream${format("%02d", count.index)}.homelab.home.arpa"
  }
}

resource "libvirt_domain" "homelab-stream" {
  depends_on = [time_sleep.wait_for_homelab-out]
  machine    = "pc-q35-8.1"
  # UEFI firmware
  nvram {
    template = "/usr/share/OVMF/OVMF_VARS.fd"
    # This is the file which will back the UEFI NVRAM content.
    file = "/var/lib/libvirt/qemu/nvram/homelab-stream${format("%02d", count.index)}.fd"
  }
  name   = "homelab-stream${format("%02d", count.index)}"
  memory = var.stream_memory
  vcpu   = var.stream_vcpu
  cpu {
    mode = "host-passthrough"
  }
  cloudinit  = libvirt_cloudinit_disk.homelab-stream_cinit[count.index].id
  qemu_agent = true

  # eth0
  network_interface {
    network_name   = "homelab-main"
    hostname       = "homelab-stream${format("%02d", count.index)}.homelab.home.arpa"
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
    volume_id = libvirt_volume.homelab-stream_vol[count.index].id
  }
  xml {
    xslt = file("sata-cloudinit.xsl")
  }
  count = var.stream_quantity
}
