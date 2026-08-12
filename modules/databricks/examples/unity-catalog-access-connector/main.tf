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

module "databricks" {
  source = "../.."

  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = "premium"
  public_network_access_enabled = false
  inherit_resource_group_tags   = false
  inherited_resource_group_tags = {}

  create_access_connector          = true
  default_storage_firewall_enabled = true

  access_connector_role_assignments = {
    external_storage = {
      scope                = var.external_storage_account_id
      role_definition_name = "Storage Blob Data Contributor"
      description          = "Unity Catalog access to external data storage."
    }
  }

  tags = {
    Environment = "prod"
    Purpose     = "UnityCatalog"
    ManagedBy   = "Terraform"
  }
}
