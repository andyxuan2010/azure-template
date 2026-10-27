terraform {
  required_version = ">= 1.6.0"

  required_providers {
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

module "management_group" {
  source = "../.."

  name                       = var.name
  display_name               = var.display_name
  parent_management_group_id = var.parent_management_group_id

  tags = {
    Owner = "Cloud Governance"
  }
}
