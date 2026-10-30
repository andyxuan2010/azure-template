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

module "app_service_plan" {
  source = "../.."

  name                            = var.name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  app_env                         = "prod"
  os_type                         = "Linux"
  sku_name                        = "P1v3"
  worker_count                    = 3
  zone_balancing_enabled          = true
  premium_plan_auto_scale_enabled = true
  inherit_resource_group_tags     = false
  inherited_resource_group_tags   = {}

  enable_diagnostics         = true
  log_analytics_workspace_id = var.log_analytics_workspace_id
  diagnostic_metrics         = ["AllMetrics"]

  app_admin_group = var.app_admin_group_object_ids
  app_user_group  = var.app_user_group_object_ids

  tags = {
    Environment    = "prod"
    Owner          = "Platform"
    BusinessImpact = "High"
    DataClass      = "Internal"
  }
}
