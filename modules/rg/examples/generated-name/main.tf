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

provider "random" {}

module "resource_group" {
  source = "../.."

  name                        = ""
  name_prefix                 = "rg"
  workload_name               = var.workload_name
  app_env                     = var.environment
  include_environment_in_name = true
  location                    = var.location
  location_code               = var.location_code
  instance                    = var.instance
  use_random_suffix           = false

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
