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
    platform_readers = {
      scope                = var.subscription_id
      role_definition_name = "Reader"
      principal_name       = var.platform_reader_group_name
      principal_type       = "Group"
    }

    application_contributor = {
      scope              = var.resource_group_id
      role_definition_id = var.contributor_role_definition_id
      principal_id       = var.application_principal_id
      principal_type     = "ServicePrincipal"
    }
  }
}
