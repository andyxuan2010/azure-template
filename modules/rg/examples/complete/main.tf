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

provider "random" {}

module "resource_group" {
  source = "../.."

  name     = var.name
  location = var.location
  app_env  = "prod"

  enable_lock = true
  lock_level  = "CanNotDelete"
  lock_notes  = "Production resource group managed by Terraform."

  app_admin_group = [var.contributor_group_object_id]
  app_user_group  = [var.reader_group_object_id]

  role_assignments = {
    storage_blob_reader = {
      principal_id         = var.application_principal_id
      principal_type       = "ServicePrincipal"
      role_definition_name = "Storage Blob Data Reader"
      description          = "Read blobs in storage accounts below this resource group."
      condition            = var.rbac_condition
      condition_version    = "2.0"
    }
  }

  tags = var.tags

  timeouts = {
    create = "30m"
    read   = "5m"
    update = "30m"
    delete = "30m"
  }
}
