terraform {
  required_version = ">= 1.5"

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

module "adf" {
  source = "../.."

  name           = "platformdata"
  app_env        = var.app_env
  location       = var.location
  resource_group = var.data_factory_resource_group_name

  public_network_enabled                  = false
  managed_virtual_network_enabled         = true
  self_hosted_integration_runtime_enabled = true

  app_vm      = var.vm_name
  app_rg      = var.application_resource_group_name
  app_vnet_rg = var.network_resource_group_name
  app_vnet    = var.virtual_network_name
  app_snet    = var.subnet_name

  iac_rg = var.shared_iac_resource_group_name
  iac_kv = var.shared_key_vault_name
  iac_st = var.shared_storage_account_name

  tags = {
    Owner = "Data Platform"
  }
}
