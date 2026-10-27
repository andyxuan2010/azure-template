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

provider "azurerm" {
  alias = "prod"

  features {}
}

module "private_endpoint" {
  source = "../.."

  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
  }

  name                           = var.name
  resource_group_name            = var.resource_group_name
  location                       = var.location
  subnet_id                      = var.subnet_id
  private_connection_resource_id = var.private_connection_resource_id
  subresource_names              = var.subresource_names
  private_dns_zone_ids           = var.private_dns_zone_ids

  inherit_resource_group_tags = false
  tags                        = var.tags
}
