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
    application = {
      address_prefixes = [var.application_address_prefix]
    }
    data = {
      address_prefixes  = [var.data_address_prefix]
      service_endpoints = ["Microsoft.Storage", "Microsoft.Sql"]
    }
  }
}
