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

  subnets = {
    app-service = {
      address_prefixes = [var.address_prefix]
      delegations = {
        app_service = {
          name                    = "app-service"
          service_delegation_name = "Microsoft.Web/serverFarms"
          actions                 = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
      }
    }
  }
}
