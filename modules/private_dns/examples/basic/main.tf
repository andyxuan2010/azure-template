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

module "private_dns" {
  source = "../.."

  resource_group_name         = var.resource_group_name
  inherit_resource_group_tags = false

  zones = {
    (var.zone_name) = {
      a_records = {
        api = {
          ttl     = 300
          records = [var.api_private_ip]
        }
      }
    }
  }

  tags = var.tags
}
