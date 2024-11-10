resource "libvirt_volume" "homelab-ubuntu_vol" {
  name           = "homelab-ubuntu${format("%02d", count.index)}.qcow2"
  pool           = var.images_pool
  size           = var.ubuntu_system_disk_size
  base_volume_id = libvirt_volume.ubuntu_image.id
  count          = var.ubuntu_quantity
}

resource "libvirt_cloudinit_disk" "homelab-ubuntu_cinit" {
  name      = "homelab-ubuntu${format("%02d", count.index)}-commoninit.iso"
  pool      = var.boot_pool
  meta_data = data.template_file.homelab-ubuntu_metadata[count.index].rendered
  user_data = data.template_file.homelab-ubuntu_userdata[count.index].rendered
  count     = var.ubuntu_quantity
}

data "template_file" "homelab-ubuntu_metadata" {
  template = file("../cloud-init/homelab-ubuntu/meta-data")
  count    = var.ubuntu_quantity
  vars = {
    hostname = "homelab-ubuntu${format("%02d", count.index)}.homelab.home.arpa"
  }
}

data "template_file" "homelab-ubuntu_userdata" {
  template = file("../cloud-init/homelab-ubuntu/user-data")
  count    = var.ubuntu_quantity
  vars = {
    hostname = "homelab-ubuntu${format("%02d", count.index)}.homelab.home.arpa"
    number   = "${format("%02d", count.index)}"
  }
}

resource "libvirt_domain" "homelab-ubuntu" {
  depends_on = [time_sleep.wait_for_homelab-out]
  machine    = "pc-q35-8.1"
  # UEFI firmware
  firmware = "/usr/share/OVMF/OVMF_CODE.fd"
  nvram {
    template = "/usr/share/OVMF/OVMF_VARS.fd"
    # This is the file which will back the UEFI NVRAM content.
    file = "/var/lib/libvirt/qemu/nvram/homelab-ubuntu${format("%02d", count.index)}.fd"
  }
  name   = "homelab-ubuntu${format("%02d", count.index)}"
  memory = var.ubuntu_memory
  vcpu   = var.ubuntu_vcpu
  cpu {
    mode = "host-passthrough"
  }
  cloudinit = libvirt_cloudinit_disk.homelab-ubuntu_cinit[count.index].id

  # eth0
  network_interface {
    network_name   = "homelab-main"
    hostname       = "homelab-ubuntu${format("%02d", count.index)}.homelab.home.arpa"
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
    volume_id = libvirt_volume.homelab-ubuntu_vol[count.index].id
  }
  xml {
    xslt = file("sata-cloudinit.xsl")
  }
  count = var.ubuntu_quantity
}
