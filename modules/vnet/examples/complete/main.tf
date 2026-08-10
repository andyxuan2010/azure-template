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

module "vnet" {
  source = "../.."

  resource_group_name = var.resource_group_name
  location            = var.location
  name                = var.name
  address_space       = var.address_space
  dns_servers         = var.dns_servers

  inherited_resource_group_tags = var.inherited_resource_group_tags

  subnets = {
    application = {
      address_prefixes  = [var.application_address_prefix]
      service_endpoints = ["Microsoft.Storage"]
    }
    private-endpoints = {
      address_prefixes                  = [var.private_endpoint_address_prefix]
      private_endpoint_network_policies = "Disabled"
    }
  }

  app_admin_group = var.app_admin_group_object_ids
  app_user_group  = var.app_user_group_object_ids

  enable_diagnostics         = true
  log_analytics_workspace_id = var.log_analytics_workspace_id

  tags = var.tags
}
