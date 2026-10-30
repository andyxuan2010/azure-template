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

module "event_hubs" {
  source = "../.."

  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = "Standard"
  public_network_access_enabled = false
  local_authentication_enabled  = false
  inherit_resource_group_tags   = false
  inherited_resource_group_tags = {}

  eventhubs = {
    telemetry = {
      partition_count   = 4
      message_retention = 3
      consumer_groups = {
        processor = {
          user_metadata = "Primary stream processor."
        }
      }
    }
  }

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
