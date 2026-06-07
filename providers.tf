provider "azurerm" {
  subscription_id = "1ec5edd4-5654-4246-8027-b29ef63b3393"
  features {}
}

provider "azurerm" {
  subscription_id = "1ec5edd4-5654-4246-8027-b29ef63b3393"
  features {}
  alias = "prod"
}

provider "azurerm" {
  subscription_id = "56fff182-2a6c-42f8-9691-998891220d3d"
  features {}
  alias = "nonprod"
}

provider "azurerm" {
  subscription_id = "bb759f2e-505c-4524-9e64-8bfae839b384"
  features {}
  alias = "sbx"
}

data "azurerm_subscriptions" "available" {}
