terraform {
  required_version = ">= 1.5"

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

provider "azuread" {}

module "subnet" {
  source = "../.."

  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  virtual_network_id   = var.virtual_network_id

  subnets = {
    application = {
      address_prefixes                          = [var.application_address_prefix]
      network_security_group_id                 = var.network_security_group_id
      create_network_security_group_association = true
      route_table_id                            = var.route_table_id
      create_route_table_association            = true
    }
    private-endpoints = {
      address_prefixes                  = [var.private_endpoint_address_prefix]
      private_endpoint_network_policies = "Disabled"
    }
  }

  app_admin_group = var.app_admin_group_object_ids
  app_user_group  = var.app_user_group_object_ids
}
