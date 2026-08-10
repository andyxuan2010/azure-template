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

module "automation" {
  source = "../.."

  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  app_env                       = "dev"
  inherit_resource_group_tags   = false
  inherited_resource_group_tags = {}

  local_auth_enabled              = false
  public_access_enabled           = false
  system_managed_identity_enabled = true

  tags = {
    Environment = "dev"
    Owner       = "Platform Operations"
  }
}
