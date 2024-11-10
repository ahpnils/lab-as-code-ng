terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
    ignition = {
      source = "community-terraform-providers/ignition"
    }
  }
}

provider "libvirt" {
  uri = var.libvirt_uri
}

