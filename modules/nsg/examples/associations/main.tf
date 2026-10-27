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

module "nsg" {
  source = "../.."

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  subnet_associations = {
    application = var.application_subnet_id
  }

  network_interface_associations = {
    management = var.management_network_interface_id
  }
}
