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

provider "azuread" {}

module "firewall" {
  source = "../.."

  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku_name                      = "AZFW_Hub"
  sku_tier                      = "Standard"
  create_public_ip              = false
  virtual_hub_id                = var.virtual_hub_id
  virtual_hub_public_ip_count   = var.virtual_hub_public_ip_count
  inherit_resource_group_tags   = false
  inherited_resource_group_tags = {}

  tags = {
    Environment = "prod"
    Topology    = "VirtualWAN"
    ManagedBy   = "Terraform"
  }
}
