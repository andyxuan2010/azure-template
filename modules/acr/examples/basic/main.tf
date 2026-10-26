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
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0, < 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azurerm" {
  alias = "prod"

  features {}
}

provider "azuread" {}

module "acr" {
  source = "../.."

  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
  }

  resource_group_name           = var.resource_group_name
  location                      = var.location
  app_env                       = var.app_env
  sku                           = "Standard"
  public_network_access_enabled = false

  tags = {
    Owner = "Platform"
  }
}
