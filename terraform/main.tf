terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.8.3"
    }
    ignition = {
      source = "community-terraform-providers/ignition"
    }
  }
}

provider "libvirt" {
  uri = var.libvirt_uri
}

