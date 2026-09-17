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

module "sqlvm" {
  source = "../.."

  resource_group_name = var.resource_group_name
  location            = var.location
  workload_name       = var.workload_name
  app_env             = var.app_env
  subnet_id           = var.subnet_id
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  tags = var.tags
}
