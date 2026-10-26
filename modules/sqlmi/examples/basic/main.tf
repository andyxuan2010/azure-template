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
  sku_name                     = "GP_Gen5"
  vcores                       = 8
  storage_size_in_gb           = 512
  public_data_endpoint_enabled = false
  identity_type                = "SystemAssigned"
  inherit_resource_group_tags  = false
  tags                         = var.tags
}
