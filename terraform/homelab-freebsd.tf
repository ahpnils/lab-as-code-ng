resource "libvirt_volume" "homelab-freebsd_vol" {
  name           = "homelab-freebsd${format("%02d", count.index)}.qcow2"
  pool           = var.images_pool
  size           = var.freebsd_system_disk_size
  base_volume_id = libvirt_volume.freebsd_image.id
  count          = var.freebsd_quantity
}

resource "libvirt_cloudinit_disk" "homelab-freebsd_cinit" {
  name      = "homelab-freebsd${format("%02d", count.index)}-commoninit.iso"
  pool      = var.boot_pool
  meta_data = data.template_file.homelab-freebsd_metadata[count.index].rendered
  user_data = data.template_file.homelab-freebsd_userdata[count.index].rendered
  count     = var.freebsd_quantity
}

data "template_file" "homelab-freebsd_metadata" {
  template = file("../cloud-init/homelab-freebsd/meta-data")
  count    = var.freebsd_quantity
  vars = {
    hostname = "homelab-freebsd${format("%02d", count.index)}.homelab.home.arpa"
  }
}

data "template_file" "homelab-freebsd_userdata" {
  template = file("../cloud-init/homelab-freebsd/user-data")
  count    = var.freebsd_quantity
  vars = {
    hostname      = "homelab-freebsd${format("%02d", count.index)}.homelab.home.arpa"
    ssh_pubkey    = var.ssh_pubkey
    user_name     = var.user_name
    user_password = var.user_password
  }
}

resource "libvirt_domain" "homelab-freebsd" {
  depends_on = [time_sleep.wait_for_homelab-out]
  machine    = "pc-q35-8.1"
  # UEFI firmware
  firmware = "/usr/share/OVMF/OVMF_CODE.fd"
  nvram {
    template = "/usr/share/OVMF/OVMF_VARS.fd"
    # This is the file which will back the UEFI NVRAM content.
    file = "/var/lib/libvirt/qemu/nvram/homelab-freebsd${format("%02d", count.index)}.fd"
  }
  name   = "homelab-freebsd${format("%02d", count.index)}"
  memory = var.freebsd_memory
  vcpu   = var.freebsd_vcpu
  cpu {
    mode = "host-passthrough"
  }
  cloudinit = libvirt_cloudinit_disk.homelab-freebsd_cinit[count.index].id

  # eth0
  network_interface {
    network_name   = "homelab-main"
    hostname       = "homelab-freebsd${format("%02d", count.index)}.homelab.home.arpa"
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
    volume_id = libvirt_volume.homelab-freebsd_vol[count.index].id
  }
  xml {
    xslt = file("sata-cloudinit.xsl")
  }
  count = var.freebsd_quantity
}
