terraform {
  required_version = ">= 1.7.0"

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

module "route_table" {
  source = "../.."

  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  disable_bgp_route_propagation = var.disable_bgp_route_propagation

  inherit_resource_group_tags = false
  routes                      = var.routes
  subnet_ids                  = var.subnet_ids
  tags                        = var.tags
}
