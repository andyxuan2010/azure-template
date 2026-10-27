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
  app_env                       = "prod"
  inherit_resource_group_tags   = false
  inherited_resource_group_tags = {}

  local_auth_enabled              = false
  public_access_enabled           = false
  system_managed_identity_enabled = true
  identity_ids                    = [var.encryption_identity_id]

  encryption = {
    key_vault_key_id          = var.key_vault_key_id
    user_assigned_identity_id = var.encryption_identity_id
  }

  enable_webhook_private_endpoint = true
  enable_hrw_private_endpoint     = true
  private_endpoint_subnet_id      = var.private_endpoint_subnet_id
  private_dns_zone_id             = var.private_dns_zone_id

  enable_diagnostics         = true
  log_analytics_workspace_id = var.log_analytics_workspace_id
  diagnostic_log_categories = [
    "JobLogs",
    "JobStreams",
    "DscNodeStatus"
  ]
  diagnostic_metric_categories = ["AllMetrics"]

  app_admin_group = var.app_admin_group_object_ids
  app_user_group  = var.app_user_group_object_ids

  managed_identity_role_assignments = var.managed_identity_target_scope == null ? {} : {
    target_reader = {
      scope                = var.managed_identity_target_scope
      role_definition_name = "Reader"
    }
  }

  tags = {
    Environment    = "prod"
    Owner          = "Platform Operations"
    BusinessImpact = "High"
    DataClass      = "Internal"
  }
}
