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

module "fortigate" {
  source = "../.."

  architecture                  = "single"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  name_prefix                   = var.name_prefix
  admin_ssh_public_key          = var.admin_ssh_public_key
  create_virtual_network        = true
  create_subnets                = true
  virtual_network_name          = var.virtual_network_name
  virtual_network_address_space = ["10.30.0.0/22"]
  inherit_resource_group_tags   = false
  inherited_resource_group_tags = {}

  interfaces = {
    external = {
      role             = "external"
      subnet_name      = "snet-fortigate-external"
      address_prefixes = ["10.30.0.0/24"]
      primary          = true
      private_ip_addresses = {
        a = "10.30.0.4"
      }
    }
    internal = {
      role             = "internal"
      subnet_name      = "snet-fortigate-internal"
      address_prefixes = ["10.30.1.0/24"]
      private_ip_addresses = {
        a = "10.30.1.4"
      }
    }
  }

  tags = {
    Environment = "sbx"
    NetworkMode = "Dedicated"
    ManagedBy   = "Terraform"
  }
}
