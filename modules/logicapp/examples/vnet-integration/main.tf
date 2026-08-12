terraform {
  required_version = ">= 1.6.0"

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

module "logic_app" {
  source = "../.."

  name                                = var.name
  resource_group_name                 = var.resource_group_name
  location                            = var.location
  service_plan_id                     = var.service_plan_id
  storage_account_name                = var.storage_account_name
  storage_account_resource_group_name = var.storage_account_resource_group_name

  system_assigned_identity_enabled = true
  virtual_network_subnet_id        = var.integration_subnet_id
  vnet_route_all_enabled           = true
}
