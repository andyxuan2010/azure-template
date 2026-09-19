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

module "functionappflex" {
  source = "../.."

  name                       = var.name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  service_plan_id            = var.service_plan_id
  runtime_name               = var.runtime_name
  runtime_version            = var.runtime_version
  storage_container_endpoint = var.storage_container_endpoint
  storage_access_key         = var.storage_access_key

  identity_type                    = "SystemAssigned"
  maximum_instance_count           = 20
  instance_memory_in_mb            = 4096
  http_concurrency                 = 16
  runtime_scale_monitoring_enabled = true
  vnet_route_all_enabled           = false

  always_ready = {
    "orders-http" = 1
  }

  inherit_resource_group_tags   = false
  inherited_resource_group_tags = {}

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = var.runtime_name
    APP_ENV                  = var.app_env
  }

  tags = var.tags
}
