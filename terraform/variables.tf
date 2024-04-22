variable "images_pool" {
  default = "default"
}

variable "boot_pool" {
  default = "default"
}

variable "alpine_image_source" {
  default = "https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/cloud/nocloud_alpine-3.19.0-x86_64-bios-cloudinit-r0.qcow2"
}

variable "fedora_image_source" {
  default = "https://ftp.lip6.fr/ftp/pub/linux/distributions/fedora/releases/39/Cloud/x86_64/images/Fedora-Cloud-Base-39-1.5.x86_64.qcow2"
}

variable "libvirt_uri" {
  default = "qemu:///system"
}

variable "homelab-out_mac" {
  default = "52:54:00:ca:59:85"
}

variable "nodes_quantity" {
  default = 10
}

variable "nodes_offset" {
  default = 10
}
