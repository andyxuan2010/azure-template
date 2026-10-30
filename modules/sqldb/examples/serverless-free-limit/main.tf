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
  app_env             = "dev"

  sku_name                    = "GP_S_Gen5_2"
  backup_storage_redundancy   = "Local"
  geo_backup_enabled          = false
  auto_pause_delay_in_minutes = 60
  min_capacity                = 0.5

  use_free_limit                 = true
  free_limit_exhaustion_behavior = "AutoPause"

  azuread_authentication_only = true
  ad_admin_login_name         = var.ad_admin_login_name
  ad_admin_object_id          = var.ad_admin_object_id

  public_network_access_enabled = true
  enable_private_endpoint       = false
  enable_audit                  = false

  firewall_rules = {
    documentation_client = {
      start_ip_address = "203.0.113.10"
      end_ip_address   = "203.0.113.10"
    }
  }

  inherit_resource_group_tags = false
  tags                        = var.tags
}
