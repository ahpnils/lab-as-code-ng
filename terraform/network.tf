resource "libvirt_network" "homelab-main" {
  name      = "homelab-main"
  domain    = "homelab.home.arpa"
  mode      = "none"
  addresses = ["10.99.99.0/24"]
  autostart = true
  dhcp {
    enabled = true
  }
  dns {
    enabled = true
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
    options {
      option_name  = "dhcp-range"
      option_value = "10.99.99.10,10.99.99.254,255.255.255.0"
    }
  }
}
