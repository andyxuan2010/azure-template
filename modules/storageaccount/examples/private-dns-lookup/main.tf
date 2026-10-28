terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.0, < 4.0"
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
  alias = "prod"

  features {}
}

provider "azuread" {}

module "storageaccount" {
  source = "../.."

  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
  }

  resource_group_name = var.resource_group_name
  location            = var.location
  name                = var.name

  private_endpoint_subresource_names           = ["blob"]
  private_endpoint_subnet_name                 = var.private_endpoint_subnet_name
  private_endpoint_vnet_name                   = var.private_endpoint_vnet_name
  private_endpoint_network_resource_group_name = var.private_endpoint_network_resource_group_name
  private_dns_zone_names = {
    blob = "privatelink.blob.core.windows.net"
  }
  private_dns_zone_resource_group_name = var.private_dns_zone_resource_group_name

  grant_current_terraform_service_principal_storage_roles = false

  tags = var.tags
}
