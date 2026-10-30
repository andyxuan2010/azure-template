terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.0, < 4.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0, < 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azurerm" {
  alias           = "prod"
  subscription_id = var.shared_services_subscription_id

  features {}
}

provider "azuread" {}

module "key_vault" {
  source = "../.."

  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
    azuread      = azuread
  }

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  enable_private_endpoint                      = true
  private_endpoint_subnet_name                 = var.private_endpoint_subnet_name
  private_endpoint_vnet_name                   = var.private_endpoint_vnet_name
  private_endpoint_network_resource_group_name = var.network_resource_group_name
  private_dns_zone_name                        = "privatelink.vaultcore.azure.net"
  private_dns_zone_resource_group_name         = var.dns_resource_group_name
}
