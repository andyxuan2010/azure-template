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

module "eventgridsystemtopic" {
  source = "../.."

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  topic_type          = var.topic_type
  source_resource_id  = var.source_resource_id

  inherit_resource_group_tags   = false
  inherited_resource_group_tags = {}

  tags = var.tags
}
