
resource "libvirt_network" "homelab-main" {
  name      = "homelab-main"
  domain    = "homelab.home.arpa"
  mode      = "none"
  addresses = ["10.99.99.0/24"]
  autostart = false
  dhcp {
    enabled = true
  }
  dns {
    enabled = false
  }
  dnsmasq_options {
    options {
      option_name  = "dhcp-option"
      option_value = "3,10.99.99.2"
    }
    options {
      option_name  = "dhcp-option"
      option_value = "6,10.99.99.3"
    }
  }
}
