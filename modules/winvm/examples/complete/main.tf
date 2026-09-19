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
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

module "winvm" {
  source = "../.."

  iac_rg      = var.iac_resource_group_name
  iac_kv      = var.iac_key_vault_name
  iac_st      = var.iac_storage_account_name
  app_rg      = var.application_resource_group_name
  app_vnet_rg = var.network_resource_group_name
  app_vnet    = var.virtual_network_name
  app_snet    = var.subnet_name

  name                 = var.name
  location             = var.location
  app_env              = var.app_env
  azure-user           = var.admin_username
  azure-password       = var.admin_password
  app_vm_number        = 2
  private_ip_addresses = var.private_ip_addresses
  enable_zone_spread   = true
  availability_zones   = ["1", "2", "3"]
  disksize             = 128

  app_admin_group = var.app_admin_group_object_ids
  app_user_group  = var.app_user_group_object_ids

  enable_virtual_machine_run_command = true
  run_command_replace_trigger        = var.bootstrap_content_hash

  enable_diagnostics         = true
  log_analytics_workspace_id = var.log_analytics_workspace_id

  tags = var.tags
}
