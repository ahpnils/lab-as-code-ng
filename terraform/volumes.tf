resource "libvirt_volume" "alpine_image" {
  name   = "alpine_image.qcow2"
  source = var.alpine_image_source
}

resource "libvirt_volume" "fedora_image" {
  name   = "fedora_image.qcow2"
  source = var.fedora_image_source
}
