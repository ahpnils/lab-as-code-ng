resource "libvirt_volume" "homelab-node_vol" {
  name           = "homelab-node${format("%02d", count.index + var.nodes_offset)}.qcow2"
  pool           = var.images_pool
  size           = 10240000000 # size is in bytes
  base_volume_id = libvirt_volume.fedora_image.id
  count          = var.nodes_quantity
}

resource "libvirt_cloudinit_disk" "homelab-node_cinit" {
  name      = "homelab-node${format("%02d", count.index + var.nodes_offset)}-commoninit.iso"
  pool      = var.boot_pool
  meta_data = data.template_file.homelab-node_metadata[count.index].rendered
  user_data = data.template_file.homelab-node_userdata[count.index].rendered
  count     = var.nodes_quantity
}

data "template_file" "homelab-node_metadata" {
  template = file("../cloud-init/homelab-node/meta-data")
  count = var.nodes_quantity
  vars = {
    hostname = "homelab-node${format("%02d", count.index + var.nodes_offset)}.homelab.home.arpa"
  }
}

data "template_file" "homelab-node_userdata" {
  template = file("../cloud-init/homelab-node/user-data")
  count = var.nodes_quantity
  vars = {
    hostname = "homelab-node${format("%02d", count.index + var.nodes_offset)}.homelab.home.arpa"
    number = "${format("%02d", count.index + 10)}"
  }
}

resource "libvirt_domain" "homelab-node" {
  depends_on = [time_sleep.wait_for_homelab-out]
  machine = "q35"
  # UEFI firmware
  firmware = "/usr/share/OVMF/OVMF_CODE.fd"
  nvram {
    # This is the file which will back the UEFI NVRAM content.
    file = "/var/lib/libvirt/qemu/nvram/homelab-node${format("%02d", count.index + var.nodes_offset)}.fd"
  }
  name       = "homelab-node${format("%02d", count.index + var.nodes_offset)}"
  memory     = "1024"
  vcpu       = "1"
  cpu {
    mode = "host-passthrough"
  }
  cloudinit = libvirt_cloudinit_disk.homelab-node_cinit[count.index].id

  # eth0
  network_interface {
    network_name = "homelab-main"
    hostname = "homelab-node${format("%02d", count.index + var.nodes_offset)}.homelab.home.arpa"
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
    volume_id = libvirt_volume.homelab-node_vol[count.index].id
  }
  xml {
    xslt = file("sata-cloudinit.xsl")
  }
  count = var.nodes_quantity
}
