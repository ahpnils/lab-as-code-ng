resource "libvirt_volume" "homelab-opensuse_vol" {
  name           = "homelab-opensuse${format("%02d", count.index)}.qcow2"
  pool           = var.images_pool
  size           = var.opensuse_system_disk_size
  base_volume_id = libvirt_volume.opensuse_image.id
  count          = var.opensuse_quantity
}

resource "libvirt_cloudinit_disk" "homelab-opensuse_cinit" {
  name      = "homelab-opensuse${format("%02d", count.index)}-commoninit.iso"
  pool      = var.boot_pool
  meta_data = data.template_file.homelab-opensuse_metadata[count.index].rendered
  user_data = data.template_file.homelab-opensuse_userdata[count.index].rendered
  count     = var.opensuse_quantity
}

data "template_file" "homelab-opensuse_metadata" {
  template = file("../cloud-init/homelab-opensuse/meta-data")
  count    = var.opensuse_quantity
  vars = {
    hostname = "homelab-opensuse${format("%02d", count.index)}.homelab.home.arpa"
  }
}

data "template_file" "homelab-opensuse_userdata" {
  template = file("../cloud-init/homelab-opensuse/user-data")
  count    = var.opensuse_quantity
  vars = {
    hostname = "homelab-opensuse${format("%02d", count.index)}.homelab.home.arpa"
  }
}

resource "libvirt_domain" "homelab-opensuse" {
  depends_on = [time_sleep.wait_for_homelab-out]
  machine    = "pc-q35-8.1"
  # UEFI firmware
  nvram {
    template = "/usr/share/OVMF/OVMF_VARS.fd"
    # This is the file which will back the UEFI NVRAM content.
    file = "/var/lib/libvirt/qemu/nvram/homelab-opensuse${format("%02d", count.index)}.fd"
  }
  name   = "homelab-opensuse${format("%02d", count.index)}"
  memory = var.opensuse_memory
  vcpu   = var.opensuse_vcpu
  cpu {
    mode = "host-passthrough"
  }
  cloudinit  = libvirt_cloudinit_disk.homelab-opensuse_cinit[count.index].id
  qemu_agent = true

  # eth0
  network_interface {
    network_name   = "homelab-main"
    hostname       = "homelab-opensuse${format("%02d", count.index)}.homelab.home.arpa"
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
    volume_id = libvirt_volume.homelab-opensuse_vol[count.index].id
  }
  xml {
    xslt = file("sata-cloudinit.xsl")
  }
  count = var.opensuse_quantity
}
