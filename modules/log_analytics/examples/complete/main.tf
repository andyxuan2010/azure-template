terraform {
  required_version = ">= 1.7.0, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "log_analytics" {
  source = "../.."

  name                            = var.name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  retention_in_days               = 180
  daily_quota_gb                  = 10
  internet_ingestion_enabled      = false
  internet_query_enabled          = true
  local_authentication_disabled   = true
  allow_resource_only_permissions = true

  workload = var.workload
  app_env  = var.app_env
  tags     = var.tags
}
