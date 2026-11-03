terraform {
  required_version = ">= 1.7.0, < 2.0.0"

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

module "bastion" {
  source = "../.."

  name                   = var.name
  resource_group_name    = var.resource_group_name
  location               = var.location
  subnet_id              = var.subnet_id
  sku                    = "Standard"
  scale_units            = 4
  zones                  = ["1", "2", "3"]
  copy_paste_enabled     = true
  file_copy_enabled      = true
  ip_connect_enabled     = true
  tunneling_enabled      = true
  shareable_link_enabled = true

  workload = var.workload
  app_env  = var.app_env
  tags     = var.tags
}
