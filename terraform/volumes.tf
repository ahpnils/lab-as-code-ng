resource "libvirt_volume" "alpine_image" {
  name   = "alpine_image.qcow2"
  source = var.alpine_image_source
}
