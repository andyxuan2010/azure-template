terraform {
  required_version = ">= 1.6.0"

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

module "linux_vm" {
  source = "../.."

  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  subnet_id                     = var.subnet_id
  inherit_resource_group_tags   = false
  inherited_resource_group_tags = {}

  iac_rg                       = var.iac_resource_group_name
  iac_kv                       = var.iac_key_vault_name
  iac_kv_id                    = var.iac_key_vault_id
  iac_st                       = var.iac_storage_account_name
  iac_st_id                    = var.iac_storage_account_id
  iac_st_primary_blob_endpoint = var.iac_storage_primary_blob_endpoint

  admin_ssh_key                   = var.admin_ssh_public_key
  disable_password_authentication = true
  bastion_resource_name           = ""

  tags = {
    Environment = "dev"
    Owner       = "Application Team"
  }
}
