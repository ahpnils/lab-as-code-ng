resource "libvirt_volume" "alpine_image" {
  name   = "alpine_image.qcow2"
  source = var.alpine_image_source
}

resource "libvirt_volume" "alpinelab_image" {
  name   = "alpinelab_image.qcow2"
  source = var.alpinelab_image_source
}

resource "libvirt_volume" "fedora_image" {
  name   = "fedora_image.qcow2"
  source = var.fedora_image_source
}

resource "libvirt_volume" "debian_image" {
  name   = "debian_image.qcow2"
  source = var.debian_image_source
}

resource "libvirt_volume" "gentoo_image" {
  name   = "gentoo_image.qcow2"
  source = var.gentoo_image_source
}

resource "libvirt_volume" "arch_image" {
  name   = "arch_image.qcow2"
  source = var.arch_image_source
}

# resource "libvirt_volume" "clear_image" {
#   name   = "clear_image.qcow2"
#   source = var.clear_image_source
# }

resource "libvirt_volume" "freebsd_image" {
  name   = "freebsd_image.qcow2"
  source = var.freebsd_image_source
}

resource "libvirt_volume" "dragonflybsd_image" {
  name   = "dragonflybsd_image.qcow2"
  source = var.dragonflybsd_image_source
}

resource "libvirt_volume" "netbsd_image" {
  name   = "netbsd_image.qcow2"
  source = var.netbsd_image_source
}

resource "libvirt_volume" "openbsd_image" {
  name   = "openbsd_image.qcow2"
  source = var.openbsd_image_source
}

resource "libvirt_volume" "stream_image" {
  name   = "stream_image.qcow2"
  source = var.stream_image_source
}

resource "libvirt_volume" "ubuntu_image" {
  name   = "ubuntu_image.qcow2"
  source = var.ubuntu_image_source
}

resource "libvirt_volume" "almalinux_image" {
  name   = "almalinux_image.qcow2"
  source = var.almalinux_image_source
}

resource "libvirt_volume" "rockylinux_image" {
  name   = "rockylinux_image.qcow2"
  source = var.rockylinux_image_source
}

resource "libvirt_volume" "oraclelinux_image" {
  name   = "oraclelinux_image.qcow2"
  source = var.oraclelinux_image_source
}

resource "libvirt_volume" "opensuse_image" {
  name   = "opensuse_image.qcow2"
  source = var.opensuse_image_source
}

resource "libvirt_volume" "coreos_image" {
  name   = "coreos_image.qcow2"
  source = var.coreos_image_source
}
