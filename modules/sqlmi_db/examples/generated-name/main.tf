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

  workload = var.workload
  app_env  = var.app_env
  instance = var.instance

  inherit_resource_group_tags = false
  tags                        = var.tags
}
