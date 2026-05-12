provider "azurerm" {
  features {}
}

provider "azuread" {}

variables {
  assignments = {}
}

run "plan" {
  command = plan
}
