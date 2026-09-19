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
  inherit_resource_group_tags   = false
  inherited_resource_group_tags = {}

  interfaces = {
    external = {
      role      = "external"
      subnet_id = var.external_subnet_id
      primary   = true
      private_ip_addresses = {
        a = var.external_private_ip_address
      }
    }
    internal = {
      role      = "internal"
      subnet_id = var.internal_subnet_id
      private_ip_addresses = {
        a = var.internal_private_ip_address
      }
    }
  }

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
