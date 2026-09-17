terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.0, < 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "sqlmi_database" {
  source = "../.."

  app_sqlmi    = var.managed_instance_name
  app_sqlmi_rg = var.managed_instance_resource_group_name
  name         = var.database_name

  enable_diagnostics         = true
  log_analytics_workspace_id = var.log_analytics_workspace_id

  app_admin_group = var.app_admin_group_object_ids
  app_user_group  = var.app_user_group_object_ids

  inherit_resource_group_tags = false
  tags                        = var.tags
}
