variable "images_pool" {
  default = "default"
}

variable "boot_pool" {
  default = "default"
}

variable "alpine_image_source" {
  default = "https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/cloud/nocloud_alpine-3.19.0-x86_64-bios-cloudinit-r0.qcow2"
}

variable "libvirt_uri" {
  default = "qemu:///system"
}


