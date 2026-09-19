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
    application_container_reader = {
      scope                = var.storage_account_id
      role_definition_name = "Storage Blob Data Reader"
      principal_id         = var.principal_id
      principal_type       = "ServicePrincipal"
      condition            = "@Resource[Microsoft.Storage/storageAccounts/blobServices/containers:name] StringEqualsIgnoreCase '${var.container_name}'"
      condition_version    = "2.0"
    }
  }
}
