
resource "libvirt_network" "homelab-main" {
  name = "homelab-main"
  domain = "homelab.home.arpa"
  mode = "none"
  addresses = ["10.99.99.0/24"]
  autostart = true
  dhcp {
    enabled = true
  }
  dns {
    enabled = false
  }
}
