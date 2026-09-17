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

module "availability_set" {
  source = "../.."

  resource_group_name           = var.resource_group_name
  location                      = var.location
  workload_name                 = var.workload_name
  app_env                       = var.environment
  instance                      = "001"
  inherit_resource_group_tags   = false
  inherited_resource_group_tags = {}

  managed                      = true
  platform_fault_domain_count  = var.platform_fault_domain_count
  platform_update_domain_count = 10
  proximity_placement_group_id = var.proximity_placement_group_id

  timeouts = {
    create = "30m"
    read   = "5m"
    update = "30m"
    delete = "30m"
  }

  tags = {
    Environment = var.environment
    Workload    = var.workload_name
    ManagedBy   = "Terraform"
  }
}
