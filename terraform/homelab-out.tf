resource "libvirt_volume" "homelab-out_vol" {
  name = "homelab-out.qcow2"
  pool = var.images_pool
  base_volume_id = libvirt_volume.alpine_image.id
}

resource "libvirt_cloudinit_disk" "homelab-out_cinit" {
  name = "homelab-out-commoninit.iso"
  pool = var.boot_pool
  meta_data = data.template_file.homelab-out_metadata.rendered
  user_data = data.template_file.homelab-out_userdata.rendered
}

data "template_file" "homelab-out_metadata" {                                       
  template = file("../cloud-init/homelab-out/meta-data")                            
}                                                                                
                                                                                 
data "template_file" "homelab-out_userdata" {                                       
  template = file("../cloud-init/homelab-out/user-data")                            
}

resource "libvirt_domain" "homelab-out" {
  name = "homelab-out"
  memory = "512"
  vcpu = "1"
  cpu {
    mode = "host-passthrough"
  }
  cloudinit = libvirt_cloudinit_disk.homelab-out_cinit.id

  # eth0
  network_interface {
    macvtap = "enp4s0f0"
    # addresses  = ["192.168.6.35"]
  }

  # eth1
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
    volume_id = libvirt_volume.homelab-out_vol.id
  }

}

