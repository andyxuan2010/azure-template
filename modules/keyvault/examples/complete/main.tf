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
  alias = "prod"

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

  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  inherit_resource_group_tags   = false
  inherited_resource_group_tags = {}

  enable_private_endpoint    = true
  private_endpoint_subnet_id = var.private_endpoint_subnet_id
  private_dns_zone_id        = var.private_dns_zone_id

  app_admin_group = var.admin_group_object_ids
  app_user_group  = var.user_group_object_ids

  contacts = [{
    email = var.certificate_contact_email
    name  = "Platform Operations"
  }]

  enable_diagnostics         = true
  log_analytics_workspace_id = var.log_analytics_workspace_id

  tags = {
    Environment = "prod"
    Owner       = "Platform Team"
  }
}
