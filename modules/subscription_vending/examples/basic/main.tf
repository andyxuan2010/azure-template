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
  alias           = "vend"
  subscription_id = var.subscription_guid

  features {}
}

module "subscription_vending" {
  source = "../.."

  providers = {
    azurerm = azurerm.vend
  }

  existing_subscription_id = "/subscriptions/${var.subscription_guid}"
  management_group_id      = var.management_group_id
}
