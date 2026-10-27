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

provider "azuread" {}

module "function_app" {
  source = "../.."

  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  os_type                       = "Windows"
  service_plan_id               = var.service_plan_id
  storage_key_vault_secret_id   = var.storage_key_vault_secret_id
  inherit_resource_group_tags   = false
  inherited_resource_group_tags = {}

  system_assigned_identity_enabled = true

  application_stack = {
    dotnet_version              = "v8.0"
    use_dotnet_isolated_runtime = true
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "dotnet-isolated"
    WEBSITE_RUN_FROM_PACKAGE = "1"
  }

  tags = {
    Environment = "prod"
    Owner       = "Application Team"
  }
}
