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
  alias = "billing"

  features {}
}

module "subscription_alias" {
  source = "../.."

  providers = {
    azurerm = azurerm.billing
  }

  subscription_alias_enabled          = true
  subscription_alias_name             = var.subscription_alias_name
  name                                = var.subscription_name
  billing_scope_id                    = var.billing_scope_id
  enable_management_group_association = false
  resource_provider_registrations     = []
  bootstrap_resource_groups           = {}
}
