provider "azurerm" {
  features {}
}

variables {
  name                         = "afw-platform-dev"
  resource_group_name          = "rg-platform-dev"
  location                     = "eastus"
  subnet_id                    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network-dev/providers/Microsoft.Network/virtualNetworks/vnet-hub-dev/subnets/AzureFirewallSubnet"
  application_rule_collections = {}
  network_rule_collections     = {}
  nat_rule_collections         = {}
}

run "plan" {
  command = plan
}
