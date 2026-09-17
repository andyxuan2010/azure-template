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

module "container_web_app" {
  source = "../.."

  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  app_service_plan_id           = var.app_service_plan_id
  kind                          = "Linux"
  inherit_resource_group_tags   = false
  inherited_resource_group_tags = {}

  system_assigned_identity_enabled        = true
  container_registry_use_managed_identity = var.use_managed_identity_for_registry

  application_stack = {
    docker_image_name   = var.docker_image_name
    docker_registry_url = var.docker_registry_url
  }
}
