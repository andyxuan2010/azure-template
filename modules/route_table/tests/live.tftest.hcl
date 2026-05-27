provider "azurerm" {
  features {}
}

variables {
  name                = "rt-platform-dev"
  resource_group_name = "rg-platform-dev"
  location            = "canadacentral"
  routes = {
    default = {
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.0.4"
    }
  }
  subnet_ids = []
}

run "plan" {
  command = plan
}
