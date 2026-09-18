terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.0, < 4.0"
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

module "primary_event_hubs" {
  source = "../.."

  name                          = var.primary_namespace_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = "Standard"
  public_network_access_enabled = false
  local_authentication_enabled  = false
  inherit_resource_group_tags   = false
  inherited_resource_group_tags = {}

  disaster_recovery_config = {
    name                 = var.alias_name
    partner_namespace_id = var.secondary_namespace_id
  }

  tags = {
    Environment = "prod"
    Resiliency  = "GeoDR"
    ManagedBy   = "Terraform"
  }
}
