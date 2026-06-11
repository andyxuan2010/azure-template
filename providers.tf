provider "azurerm" {
  features {}
}

provider "azurerm" {
  features {}
  alias = "prod"
}

provider "azurerm" {
  features {}
  alias = "nonprod"
}

provider "azurerm" {
  features {}
  alias = "sbx"
}

data "azurerm_subscriptions" "available" {}
