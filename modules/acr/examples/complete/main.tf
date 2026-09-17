terraform {
  required_version = ">= 1.5"

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

module "acr" {
  source = "../.."

  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
  }

  resource_group_name           = var.resource_group_name
  location                      = var.location
  name                          = var.registry_name
  app_env                       = var.app_env
  sku                           = "Premium"
  admin_enabled                 = false
  anonymous_pull_enabled        = false
  public_network_access_enabled = false

  identity_type = "SystemAssigned"

  export_policy_enabled        = false
  quarantine_policy_enabled    = true
  retention_policy_in_days     = 14
  trust_policy_enabled         = true
  zone_redundancy_enabled      = true
  enable_private_endpoint      = true
  private_endpoint_subnet_id   = var.private_endpoint_subnet_id
  private_dns_zone_id          = var.private_dns_zone_id
  enable_diagnostics           = true
  log_analytics_workspace_id   = var.log_analytics_workspace_id
  diagnostic_log_categories    = ["ContainerRegistryRepositoryEvents", "ContainerRegistryLoginEvents"]
  diagnostic_metric_categories = ["AllMetrics"]

  georeplications = [
    {
      location                  = var.secondary_location
      regional_endpoint_enabled = true
      zone_redundancy_enabled   = true
      tags = {
        Role = "Secondary"
      }
    }
  ]

  tags = {
    Owner          = "Platform"
    DataClass      = "Internal"
    BusinessImpact = "High"
  }
}
