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
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

module "adf" {
  source = "../.."

  name                                     = "platformdata"
  app_env                                  = "prod"
  location                                 = var.location
  resource_group                           = var.resource_group_name
  identity_type                            = "SystemAssigned"
  public_network_enabled                   = false
  managed_virtual_network_enabled          = true
  create_default_azure_integration_runtime = true

  enable_private_endpoint    = true
  private_endpoint_subnet_id = var.private_endpoint_subnet_id
  private_dns_zone_id        = var.private_dns_zone_id

  managed_private_endpoint = [
    {
      name               = "storage-blob"
      target_resource_id = var.storage_account_id
      subresource_name   = "blob"
    }
  ]

  global_parameter = [
    {
      name  = "environment"
      type  = "String"
      value = "prod"
    }
  ]

  enable_diagnostics = true
  log_analytics_workspace = {
    platform = var.log_analytics_workspace_id
  }

  tags = {
    Owner          = "Data Platform"
    DataClass      = "Internal"
    BusinessImpact = "High"
  }
}
