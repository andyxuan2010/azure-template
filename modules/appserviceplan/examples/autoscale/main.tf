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
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

module "autoscaling_plan" {
  source = "../.."

  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  os_type                       = "Linux"
  sku_name                      = "S1"
  worker_count                  = 1
  inherit_resource_group_tags   = false
  inherited_resource_group_tags = {}

  enable_autoscale                      = true
  autoscale_min_capacity                = 1
  autoscale_default_capacity            = 2
  autoscale_max_capacity                = 5
  autoscale_cpu_threshold_scale_up      = 75
  autoscale_cpu_threshold_scale_down    = 25
  enable_memory_autoscale               = true
  autoscale_memory_threshold_scale_up   = 80
  autoscale_memory_threshold_scale_down = 40

  autoscale_notifications = {
    email = {
      custom_emails = var.autoscale_notification_emails
    }
  }

  tags = {
    Environment = "prod"
    Owner       = "Application Team"
  }
}
