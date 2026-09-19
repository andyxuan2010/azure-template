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

  name           = var.name
  location       = var.location
  app_env        = var.app_env
  azure-user     = var.admin_username
  azure-password = var.admin_password

  app_admin_group = []
  app_user_group  = []

  enable_virtual_machine_run_command = true
  enable_shir                        = true
  adf_id                             = var.data_factory_id

  tags = var.tags
}
