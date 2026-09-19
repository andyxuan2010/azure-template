terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "staticwebapp" {
  source = "../.."

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  app_settings = {
    APP_ENV = var.app_env
  }

  identity_type                      = "SystemAssigned"
  preview_environments_enabled       = true
  public_network_access_enabled      = true
  configuration_file_changes_enabled = true

  inherit_resource_group_tags   = false
  inherited_resource_group_tags = {}
  tags                          = var.tags
}
