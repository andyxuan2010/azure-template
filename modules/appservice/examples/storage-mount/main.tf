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

module "web_app_with_storage" {
  source = "../.."

  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  app_service_plan_id           = var.app_service_plan_id
  kind                          = "Linux"
  inherit_resource_group_tags   = false
  inherited_resource_group_tags = {}

  app_settings = {
    STORAGE_ACCESS_KEY = var.storage_access_key
  }

  storage_accounts = [
    {
      name                    = "data"
      account_name            = var.storage_account_name
      access_key_setting_name = "STORAGE_ACCESS_KEY"
      share_name              = var.storage_share_name
      mount_path              = "/mnt/data"
      type                    = "AzureFiles"
    }
  ]
}
