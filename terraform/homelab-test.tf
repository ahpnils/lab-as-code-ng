resource "libvirt_volume" "homelab-test_vol" {
  name           = "homelab-test.qcow2"
  pool           = var.images_pool
  size           = 10240000000 # size is in bytes
  base_volume_id = libvirt_volume.alpine_image.id
}

resource "libvirt_cloudinit_disk" "homelab-test_cinit" {
  name      = "homelab-test-commoninit.iso"
  pool      = var.boot_pool
  meta_data = data.template_file.homelab-test_metadata.rendered
  user_data = data.template_file.homelab-test_userdata.rendered
}

data "template_file" "homelab-test_metadata" {
  template = file("../cloud-init/homelab-test/meta-data")
}

data "template_file" "homelab-test_userdata" {
  template = file("../cloud-init/homelab-test/user-data")
}

resource "libvirt_domain" "homelab-test" {
  depends_on = [time_sleep.wait_for_homelab-out]
  name       = "homelab-test"
  memory     = "512"
  vcpu       = "1"
  cpu {
    mode = "host-passthrough"
  }
  cloudinit = libvirt_cloudinit_disk.homelab-test_cinit.id

  # eth0
  network_interface {
    network_name = "homelab-main"
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
    volume_id = libvirt_volume.homelab-test_vol.id
  }

}

