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

  resource_group_name            = var.resource_group_name
  location                       = var.location
  private_connection_resource_id = var.private_connection_resource_id
  subresource_names              = [var.subresource_name]

  subnet_name                         = var.subnet_name
  virtual_network_name                = var.virtual_network_name
  virtual_network_resource_group_name = var.virtual_network_resource_group_name

  private_dns_zone_names               = [var.private_dns_zone_name]
  private_dns_zone_resource_group_name = var.private_dns_zone_resource_group_name

  workload                    = var.workload
  app_env                     = var.environment
  instance                    = var.instance
  inherit_resource_group_tags = false
}
