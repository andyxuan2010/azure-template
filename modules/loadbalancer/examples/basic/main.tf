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

module "load_balancer" {
  source = "../.."

  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  inherit_resource_group_tags   = false
  inherited_resource_group_tags = {}

  frontend_ip_configurations = [{
    name                          = "internal"
    subnet_id                     = var.frontend_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.frontend_private_ip_address
  }]

  backend_address_pools = [{
    name = "application"
  }]

  tags = {
    Environment = "dev"
    Owner       = "Network Team"
  }
}
