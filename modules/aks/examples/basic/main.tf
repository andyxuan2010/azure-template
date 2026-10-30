terraform {
  required_version = ">= 1.6"

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

module "aks" {
  source = "../.."

  resource_group_name = var.resource_group_name
  location            = var.location
  workload_name       = var.workload_name
  app_env             = var.app_env
  private_dns_zone_id = "System"

  default_node_pool = {
    name                 = "system"
    vm_size              = var.system_node_vm_size
    auto_scaling_enabled = true
    min_count            = 1
    max_count            = 3
    vnet_subnet_id       = var.subnet_id
  }

  app_admin_group = var.admin_group_object_ids

  tags = {
    Owner = "Platform"
  }
}
