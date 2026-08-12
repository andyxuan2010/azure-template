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
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

module "windows_web_app" {
  source = "../.."

  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  app_service_plan_id           = var.app_service_plan_id
  kind                          = "Windows"
  inherit_resource_group_tags   = false
  inherited_resource_group_tags = {}

  system_assigned_identity_enabled = true
  use_32_bit_worker                = false

  application_stack = {
    current_stack  = "dotnet"
    dotnet_version = "v8.0"
  }
}
