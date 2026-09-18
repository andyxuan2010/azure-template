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

provider "azurerm" {
  alias = "prod"

  features {}
}

provider "azuread" {}

module "storageaccount" {
  source = "../.."

  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
  }

  resource_group_name = var.resource_group_name
  location            = var.location
  name                = var.name

  system_managed_identity_enabled = true
  containers = {
    artifacts = {
      container_access_type = "private"
    }
  }

  private_endpoint_subresource_names = ["blob", "dfs"]
  private_endpoint_subnet_id         = var.private_endpoint_subnet_id
  private_dns_zone_ids               = var.private_dns_zone_ids

  enable_diagnostics         = true
  log_analytics_workspace_id = var.log_analytics_workspace_id

  grant_current_terraform_service_principal_storage_roles = false

  tags = var.tags
}
