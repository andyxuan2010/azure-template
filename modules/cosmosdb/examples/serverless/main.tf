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

module "cosmos" {
  source = "../.."

  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  inherit_resource_group_tags   = false
  inherited_resource_group_tags = {}

  capabilities                  = ["EnableServerless"]
  public_network_access_enabled = false
  local_authentication_disabled = true

  sql_databases = {
    application = {}
  }

  sql_containers = {
    events = {
      database_name       = "application"
      partition_key_paths = ["/tenantId"]
      default_ttl         = 2592000
    }
  }

  tags = {
    Environment = "dev"
    Capacity    = "Serverless"
    ManagedBy   = "Terraform"
  }
}
