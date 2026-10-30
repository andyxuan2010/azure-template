terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "log_analytics" {
  source = "../.."

  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  inherit_resource_group_tags   = false
  inherited_resource_group_tags = {}

  sku                                = "CapacityReservation"
  reservation_capacity_in_gb_per_day = var.reservation_capacity_in_gb_per_day
  retention_in_days                  = 90
  daily_quota_gb                     = var.daily_quota_gb

  local_authentication_disabled = true
  internet_ingestion_enabled    = false
  internet_query_enabled        = false
  data_collection_rule_id       = var.data_collection_rule_id

  identity = {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "prod"
    Owner       = "Observability Team"
  }
}
