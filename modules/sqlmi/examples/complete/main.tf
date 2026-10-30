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

module "sqlmi" {
  source = "../.."

  name                         = var.name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  subnet_id                    = var.subnet_id
  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_login_password

  sku_name           = "GP_Gen5"
  vcores             = 8
  storage_size_in_gb = 512
  license_type       = var.license_type

  minimum_tls_version          = "1.2"
  public_data_endpoint_enabled = false
  proxy_override               = "Redirect"

  identity_type = "SystemAssigned, UserAssigned"
  identity_ids  = [var.user_assigned_identity_id]

  azure_active_directory_administrator = {
    login_username                      = var.entra_admin_login_name
    object_id                           = var.entra_admin_object_id
    principal_type                      = "Group"
    azuread_authentication_only_enabled = true
  }

  enable_diagnostics         = true
  log_analytics_workspace_id = var.log_analytics_workspace_id

  app_admin_group = var.app_admin_group_object_ids
  app_user_group  = var.app_user_group_object_ids

  inherit_resource_group_tags = false
  tags                        = var.tags
}
