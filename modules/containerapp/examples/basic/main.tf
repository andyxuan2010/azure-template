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

module "container_app" {
  source = "../.."

  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  container_app_environment_id  = var.container_app_environment_id
  inherit_resource_group_tags   = false
  inherited_resource_group_tags = {}

  containers = [{
    name   = "web"
    image  = var.container_image
    cpu    = 0.25
    memory = "0.5Gi"
  }]

  ingress = {
    external_enabled = true
    target_port      = 80
  }

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
