variable "images_pool" {
  default = "default"
}

variable "boot_pool" {
  default = "default"
}

# https://www.alpinelinux.org/cloud/
variable "alpine_image_source" {
  default = "https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/cloud/nocloud_alpine-3.19.0-x86_64-bios-cloudinit-r0.qcow2"
}

variable "alpinelab_image_source" {
  default = "https://dl-cdn.alpinelinux.org/alpine/v3.20/releases/cloud/nocloud_alpine-3.20.3-x86_64-uefi-cloudinit-r0.qcow2"
}

# https://fedoraproject.org/cloud/download
variable "fedora_image_source" {
  default = "https://download.fedoraproject.org/pub/fedora/linux/releases/40/Cloud/x86_64/images/Fedora-Cloud-Base-Generic.x86_64-40-1.14.qcow2"
}

# https://cloud.centos.org/centos/
variable "stream_image_source" {
  #default = "https://composes.stream.centos.org/stream-10/production/latest-CentOS-Stream/compose/BaseOS/x86_64/images/CentOS-Stream-GenericCloud-10-20241004.0.x86_64.qcow2"
  #default = "https://composes.stream.centos.org/stream-10/production/latest-CentOS-Stream/compose/BaseOS/x86_64/images/CentOS-Stream-GenericCloud-x86_64-10-20241004.0.x86_64.qcow2"
  default = "https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-9-20240930.0.x86_64.qcow2"
}

# https://cloud.debian.org/images/cloud/
variable "debian_image_source" {
  # https://mop.koeln/blog/creating-a-local-debian-vm-using-cloud-init-and-libvirt/
  # Obviously this sounds like the right image. Unfortunately it is not. It doesn't contain 
  # the SATA AHCI drivers which are needed because of the way the cloud-init stuff is being 
  # injected into the VM (as a cdrom drive).
  # default = "https://cloud.debian.org/images/cloud/bookworm/daily/latest/debian-12-genericcloud-amd64-daily.qcow2"
  default = "https://cloud.debian.org/images/cloud/bookworm/daily/latest/debian-12-generic-amd64-daily.qcow2"
}

# https://www.gentoo.org/downloads/
# Look for "Experimental downloads" at the bottom
variable "gentoo_image_source" {
  default = "https://distfiles.gentoo.org/experimental/amd64/openstack/gentoo-openstack-amd64-default-nomultilib-20230421.qcow2"
}

# https://gitlab.archlinux.org/archlinux/arch-boxes/
variable "arch_image_source" {
  default = "https://gitlab.archlinux.org/archlinux/arch-boxes/-/package_files/7529/download"
}

# https://www.clearlinux.org/downloads.html
# KVM image for UEFI
# KVM Legacy for BIOS
variable "clear_image_source" {
  # Clear Linux images are compressed on their servers but Terraform or the libvirt provider
  # does not support it. Therefore, you need to provide your own web server with
  # uncompressed cloud images.
  # default = "https://cdn.download.clearlinux.org/releases/42390/clear/clear-42390-cloudguest.img.xz"
  default = "http://192.168.6.66/clear-42390-cloudguest.img"
}

# https://bsd-cloud-image.org/
variable "freebsd_image_source" {
  default = "https://object-storage.public.mtl1.vexxhost.net/swift/v1/1dbafeefbd4f4c80864414a441e72dd2/bsd-cloud-image.org/images/freebsd/14.0/2024-05-06/zfs/freebsd-14.0-zfs-2024-05-06.qcow2"
}

# https://bsd-cloud-image.org/
variable "dragonflybsd_image_source" {
  default = "https://object-storage.public.mtl1.vexxhost.net/swift/v1/1dbafeefbd4f4c80864414a441e72dd2/bsd-cloud-image.org/images/dragonflybsd/6.4.0/2023-04-23/hammer2/dragonflybsd-6.4.0-hammer2-2023-04-23.qcow2"
}

# https://bsd-cloud-image.org/
variable "netbsd_image_source" {
  default = "https://object-storage.public.mtl1.vexxhost.net/swift/v1/1dbafeefbd4f4c80864414a441e72dd2/bsd-cloud-image.org/images/netbsd/9.3/2023-04-23/ufs/netbsd-9.3-2023-04-23.qcow2"
}

# https://bsd-cloud-image.org/
variable "openbsd_image_source" {
  default = "https://github.com/hcartiaux/openbsd-cloud-image/releases/download/v7.5_2024-05-13-15-25/openbsd-min.qcow2"
}

# https://cloud-images.ubuntu.com/
variable "ubuntu_image_source" {
  default = "https://cloud-images.ubuntu.com/noble/20241004/noble-server-cloudimg-amd64.img"
}

# https://wiki.almalinux.org/cloud/
variable "almalinux_image_source" {
  default = "https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-9.4-20240805.x86_64.qcow2"
}

# http://dl.rockylinux.org/pub/rocky/9/images/x86_64/
variable "rockylinux_image_source" {
  default = "http://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-LVM-9.4-20240609.0.x86_64.qcow2"
}

# https://yum.oracle.com/oracle-linux-templates.html
variable "oraclelinux_image_source" {
  default = "https://yum.oracle.com/templates/OracleLinux/OL9/u4/x86_64/OL9U4_x86_64-kvm-b234.qcow2"
}

# https://download.opensuse.org/repositories/Cloud:/Images:/
variable "opensuse_image_source" {
  default = "https://download.opensuse.org/repositories/Cloud:/Images:/Leap_15.6/images/openSUSE-Leap-15.6.x86_64-1.0.1-NoCloud-Build1.88.qcow2"
}

# https://fedoraproject.org/coreos/download?stream=stable#arches
# images are compressed with XZ.
variable "coreos_image_source" {
  default = "http://192.168.6.66/fedora-coreos-40.20241019.3.0-qemu.x86_64.qcow2"
}

variable "libvirt_uri" {
  default = "qemu:///system"
}

variable "homelab-out_mac" {
  default = "52:54:00:ca:59:85"
}

variable "fedora_quantity" {
  default = 1
}

variable "fedora_system_disk_size" {
  default = 10240000000 # size is in bytes
}

variable "fedora_vcpu" {
  default = 1
}

variable "fedora_memory" {
  default = 1024 # size is in Megabytes
}

variable "debian_quantity" {
  default = 0
}

variable "debian_system_disk_size" {
  default = 10240000000 # size is in bytes
}

variable "debian_vcpu" {
  default = 1
}

variable "debian_memory" {
  default = 1024 # size is in Megabytes
}

variable "alpinelab_quantity" {
  default = 0
}

variable "alpine_system_disk_size" {
  default = 10240000000 # size is in bytes
}

variable "alpinelab_system_disk_size" {
  default = 10240000000 # size is in bytes
}

variable "alpinelab_vcpu" {
  default = 1
}

variable "alpinelab_memory" {
  default = 512 # size is in Megabytes
}

variable "gentoo_quantity" {
  default = 0
}

variable "gentoo_system_disk_size" {
  default = 10240000000 # size is in bytes
}

variable "gentoo_vcpu" {
  default = 1
}

variable "gentoo_memory" {
  default = 1024 # size is in Megabytes
}

variable "arch_quantity" {
  default = 0
}

variable "arch_system_disk_size" {
  default = 10240000000 # size is in bytes
}

variable "arch_vcpu" {
  default = 1
}

variable "arch_memory" {
  default = 1024 # size is in Megabytes
}


variable "clear_quantity" {
  default = 0
}

variable "clear_system_disk_size" {
  default = 10240000000 # size is in bytes
}

variable "clear_vcpu" {
  default = 1
}

variable "clear_memory" {
  default = 1024 # size is in Megabytes
}


variable "freebsd_quantity" {
  default = 0
}

variable "freebsd_system_disk_size" {
  default = 10240000000 # size is in bytes
}

variable "freebsd_vcpu" {
  default = 1
}

variable "freebsd_memory" {
  default = 1024 # size is in Megabytes
}

variable "dragonflybsd_quantity" {
  default = 0
}

variable "dragonflybsd_system_disk_size" {
  default = 10240000000 # size is in bytes
}

variable "dragonflybsd_vcpu" {
  default = 1
}

variable "dragonflybsd_memory" {
  default = 1024 # size is in Megabytes
}

variable "netbsd_quantity" {
  default = 0
}

variable "netbsd_system_disk_size" {
  default = 10240000000 # size is in bytes
}

variable "netbsd_vcpu" {
  default = 1
}

variable "netbsd_memory" {
  default = 1024 # size is in Megabytes
}

variable "openbsd_quantity" {
  default = 0
}

variable "openbsd_system_disk_size" {
  default = 17408000000 # size is in bytes
}

variable "openbsd_vcpu" {
  default = 1
}

variable "openbsd_memory" {
  default = 1024 # size is in Megabytes
}

variable "stream_quantity" {
  default = 0
}

variable "stream_system_disk_size" {
  default = 12240000000 # size is in bytes
}

variable "stream_vcpu" {
  default = 1
}

variable "stream_memory" {
  default = 1024 # size is in Megabytes
}

variable "ubuntu_quantity" {
  default = 0
}

variable "ubuntu_system_disk_size" {
  default = 10240000000 # size is in bytes
}

variable "ubuntu_vcpu" {
  default = 1
}

variable "ubuntu_memory" {
  default = 1024 # size is in Megabytes
}

variable "almalinux_quantity" {
  default = 1
}

variable "almalinux_system_disk_size" {
  default = 12240000000 # size is in bytes
}

variable "almalinux_vcpu" {
  default = 1
}

variable "almalinux_memory" {
  default = 2048 # size is in Megabytes
}

variable "rockylinux_quantity" {
  default = 0
}

variable "rockylinux_system_disk_size" {
  default = 12240000000 # size is in bytes
}

variable "rockylinux_vcpu" {
  default = 1
}

variable "rockylinux_memory" {
  default = 2048 # size is in Megabytes
}

variable "oraclelinux_quantity" {
  default = 1
}

variable "oraclelinux_system_disk_size" {
  default = 40960000000 # size is in bytes
}

variable "oraclelinux_vcpu" {
  default = 1
}

variable "oraclelinux_memory" {
  default = 2048 # size is in Megabytes
}

variable "opensuse_quantity" {
  default = 1
}

variable "opensuse_system_disk_size" {
  default = 12240000000 # size is in bytes
}

variable "opensuse_vcpu" {
  default = 1
}

variable "opensuse_memory" {
  default = 1024 # size is in Megabytes
}

variable "coreos_quantity" {
  default = 1
}

variable "coreos_system_disk_size" {
  default = 12240000000 # size is in bytes
}

variable "coreos_vcpu" {
  default = 1
}

variable "coreos_memory" {
  default = 1024 # size is in Megabytes
}
