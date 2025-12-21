resource "libvirt_volume" "homelab-alpine_vol" {
  name           = "homelab-alpine${format("%02d", count.index)}.qcow2"
  pool           = var.images_pool
  size           = var.alpinelab_system_disk_size
  base_volume_id = libvirt_volume.alpinelab_image.id
  count          = var.alpinelab_quantity
}

resource "libvirt_cloudinit_disk" "homelab-alpine_cinit" {
  name      = "homelab-alpine${format("%02d", count.index)}-commoninit.iso"
  pool      = var.boot_pool
  meta_data = data.template_file.homelab-alpine_metadata[count.index].rendered
  user_data = data.template_file.homelab-alpine_userdata[count.index].rendered
  count     = var.alpinelab_quantity
}

data "template_file" "homelab-alpine_metadata" {
  template = file("../cloud-init/homelab-alpine/meta-data")
  count    = var.alpinelab_quantity
  vars = {
    hostname = "homelab-alpine${format("%02d", count.index)}.homelab.home.arpa"
  }
}

data "template_file" "homelab-alpine_userdata" {
  template = file("../cloud-init/homelab-alpine/user-data")
  count    = var.alpinelab_quantity
  vars = {
    hostname      = "homelab-alpine${format("%02d", count.index)}.homelab.home.arpa"
    ssh_pubkey    = var.ssh_pubkey
    user_name     = var.user_name
    user_password = var.user_password
  }
}

resource "libvirt_domain" "homelab-alpine" {
  depends_on = [time_sleep.wait_for_homelab-out]
  machine    = "pc-q35-8.1"
  # UEFI firmware
  firmware = "/usr/share/OVMF/OVMF_CODE.fd"
  nvram {
    template = "/usr/share/OVMF/OVMF_VARS.fd"
    # This is the file which will back the UEFI NVRAM content.
    file = "/var/lib/libvirt/qemu/nvram/homelab-alpine${format("%02d", count.index)}.fd"
  }
  name   = "homelab-alpine${format("%02d", count.index)}"
  memory = var.alpinelab_memory
  vcpu   = var.alpinelab_vcpu
  cpu {
    mode = "host-passthrough"
  }
  cloudinit = libvirt_cloudinit_disk.homelab-alpine_cinit[count.index].id

  # eth0
  network_interface {
    network_name   = "homelab-main"
    hostname       = "homelab-alpine${format("%02d", count.index)}.homelab.home.arpa"
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
    volume_id = libvirt_volume.homelab-alpine_vol[count.index].id
  }
  xml {
    xslt = file("sata-cloudinit.xsl")
  }
  count = var.alpinelab_quantity
  provisioner "local-exec" {
    when    = destroy
    command = "ssh-keygen -R ${self.network_interface.0.addresses.0}"
  }
}

resource "local_file" "homelab-alpine-ssh_config" {
  content = templatefile("ssh_config.tpl", {
    node_name         = libvirt_domain.homelab-alpine[count.index].*.name,
    node_ip           = libvirt_domain.homelab-alpine[count.index].network_interface.0.addresses.0
    user_name         = var.user_name
    ssh_identity_file = var.ssh_identity_file
  })
  count           = var.alpinelab_quantity
  filename        = "${var.ssh_filepath}homelab-alpine${format("%02d", count.index)}.conf"
  file_permission = "0644"
}
