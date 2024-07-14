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
  default = "https://download.fedoraproject.org/pub/fedora/linux/releases/40/Cloud/x86_64/images/Fedora-Cloud-Base-Generic.x86_64-40-1.14.qcow2"
}

variable "debian_image_source" {
  # https://mop.koeln/blog/creating-a-local-debian-vm-using-cloud-init-and-libvirt/
  # Obviously this sounds like the right image. Unfortunately it is not. It doesn't contain 
  # the SATA AHCI drivers which are needed because of the way the cloud-init stuff is being 
  # injected into the VM (as a cdrom drive).
  # default = "https://cloud.debian.org/images/cloud/bookworm/daily/latest/debian-12-genericcloud-amd64-daily.qcow2"
  default = "https://cloud.debian.org/images/cloud/bookworm/daily/latest/debian-12-generic-amd64-daily.qcow2"
}

variable "libvirt_uri" {
  default = "qemu:///system"
}

variable "homelab-out_mac" {
  default = "52:54:00:ca:59:85"
}

variable "nodes_quantity" {
  default = 0
}

variable "nodes_offset" {
  default = 10
}

variable "control_quantity" {
  default = 6
}

variable "control_offset" {
  default = 20
}

variable "worker_quantity" {
  default = 10
}

variable "worker_offset" {
  default = 30
}
