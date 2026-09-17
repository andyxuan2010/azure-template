terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = ">= 2.0, < 3.0"
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

module "sqldb" {
  source = "../.."

  resource_group_name = var.resource_group_name
  location            = var.location
  server_name         = var.server_name
  name                = var.database_name
  app_env             = "prod"

  sku_name    = "GP_Gen5_2"
  max_size_gb = 64

  azuread_authentication_only = true
  ad_admin_login_name         = var.ad_admin_login_name
  ad_admin_object_id          = var.ad_admin_object_id

  public_network_access_enabled = false
  enable_private_endpoint       = true
  private_endpoint_subnet_id    = var.private_endpoint_subnet_id
  private_dns_zone_ids          = [var.private_dns_zone_id]

  enable_diagnostics         = true
  log_analytics_workspace_id = var.log_analytics_workspace_id
  diagnostic_log_categories  = ["AllLogs"]

  enable_database_audit = true

  enable_long_term_retention = true
  long_term_retention_policy = {
    weekly_retention          = 12
    monthly_retention         = 12
    yearly_retention          = 3
    week_of_year              = 1
    immutable_backups_enabled = true
  }

  app_admin_group = var.app_admin_group_object_ids
  app_user_group  = var.app_user_group_object_ids

  inherit_resource_group_tags = false
  tags                        = var.tags
}
