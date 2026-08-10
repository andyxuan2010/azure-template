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
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0, < 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

module "openai" {
  source = "../.."

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  identity_ids = [var.user_assigned_identity_id]

  customer_managed_key = {
    key_vault_key_id   = var.key_vault_key_id
    identity_client_id = var.user_assigned_identity_client_id
  }
}
