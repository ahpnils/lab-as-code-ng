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
    hostname      = "homelab-ubuntu${format("%02d", count.index)}.homelab.home.arpa"
    ssh_pubkey    = var.ssh_pubkey
    user_name     = var.user_name
    user_password = var.user_password
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
  provisioner "local-exec" {
    when    = destroy
    command = "ssh-keygen -R ${self.network_interface.0.addresses.0}"
  }
  count = var.ubuntu_quantity
}

resource "local_file" "homelab-ubuntu-ssh_config" {
  content = templatefile("ssh_config.tpl", {
    node_name         = libvirt_domain.homelab-ubuntu[count.index].*.name,
    node_ip           = libvirt_domain.homelab-ubuntu[count.index].network_interface.0.addresses.0
    user_name         = var.user_name
    ssh_identity_file = var.ssh_identity_file
  })
  count           = var.ubuntu_quantity
  filename        = "${var.ssh_filepath}homelab-ubuntu${format("%02d", count.index)}.conf"
  file_permission = "0644"
}
