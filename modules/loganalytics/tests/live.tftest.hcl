provider "azurerm" {
  features {}
}

variables {
  name                = "law-platform-dev"
  resource_group_name = "rg-platform-dev"
  location            = "eastus"
  retention_in_days   = 30
}

run "plan" {
  command = plan
}
