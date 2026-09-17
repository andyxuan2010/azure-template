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
  inherit_resource_group_tags         = false
  inherited_resource_group_tags       = {}

  system_assigned_identity_enabled = true
  virtual_network_subnet_id        = var.integration_subnet_id
  vnet_route_all_enabled           = true

  enable_private_endpoint    = true
  private_endpoint_subnet_id = var.private_endpoint_subnet_id
  private_dns_zone_id        = var.private_dns_zone_id

  enable_diagnostics         = true
  log_analytics_workspace_id = var.log_analytics_workspace_id

  app_admin_group = var.admin_group_object_ids
  app_user_group  = var.user_group_object_ids

  app_settings = {
    WEBSITE_NODE_DEFAULT_VERSION = "~20"
  }

  tags = {
    Environment = "prod"
    Owner       = "Integration Team"
  }
}
