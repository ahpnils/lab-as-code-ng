resource "libvirt_volume" "homelab-coreos_vol" {
  name           = "homelab-coreos${format("%02d", count.index)}.qcow2"
  pool           = var.images_pool
  size           = var.coreos_system_disk_size
  base_volume_id = libvirt_volume.coreos_image.id
  count          = var.coreos_quantity
}

resource "libvirt_ignition" "homelab-coreos_ignition" {
  name      = "homelab-coreos${format("%02d", count.index)}-ignition.ign"
  content   = element(data.ignition_config.startup.*.rendered, count.index)
  pool      = var.boot_pool
  count     = var.coreos_quantity
}


resource "libvirt_domain" "homelab-coreos" {
  depends_on = [time_sleep.wait_for_homelab-out]
  machine    = "pc-q35-8.1"
  # UEFI firmware
  nvram {
    template = "/usr/share/OVMF/OVMF_VARS.fd"
    # This is the file which will back the UEFI NVRAM content.
    file = "/var/lib/libvirt/qemu/nvram/homelab-coreos${format("%02d", count.index)}.fd"
  }
  name   = "homelab-coreos${format("%02d", count.index)}"
  memory = var.coreos_memory
  vcpu   = var.coreos_vcpu
  cpu {
    mode = "host-passthrough"
  }
  coreos_ignition = element(libvirt_ignition.homelab-coreos_ignition.*.id, count.index)
  #qemu_agent = true

  # eth0
  network_interface {
    network_name   = "homelab-main"
    hostname       = "homelab-coreos${format("%02d", count.index)}.homelab.home.arpa"
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
    volume_id = libvirt_volume.homelab-coreos_vol[count.index].id
  }
  xml {
    xslt = file("sata-cloudinit.xsl")
  }
  count = var.coreos_quantity
}
