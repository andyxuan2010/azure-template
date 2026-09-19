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
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

module "role_assignments" {
  source = "../.."

  assignments = {
    application_reader = {
      scope                = var.resource_group_id
      role_definition_name = "Reader"
      principal_id         = var.principal_id
      principal_type       = "Group"
    }
  }
}
