provider "azurerm" {
  features {}
}

variables {
  resource_group_name = "rg-platform-dev"
  zones = {
    "privatelink.vaultcore.azure.net" = {
      vnet_links = {}
      a_records  = {}
    }
  }
}

run "plan" {
  command = plan
}
