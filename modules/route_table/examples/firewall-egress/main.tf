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

module "firewall_egress" {
  source = "../.."

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  inherit_resource_group_tags = false

  routes = {
    default_to_firewall = {
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = var.firewall_private_ip
    }
  }

  subnet_ids = var.workload_subnet_ids
  tags       = var.tags
}
