terraform {
  required_version = ">= 1.5"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.0, < 4.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

module "adf" {
  source = "../.."

  name                                     = "platformdata"
  app_env                                  = var.app_env
  location                                 = var.location
  resource_group                           = var.resource_group_name
  public_network_enabled                   = false
  managed_virtual_network_enabled          = true
  create_default_azure_integration_runtime = true

  tags = {
    Owner = "Data Platform"
  }
}
