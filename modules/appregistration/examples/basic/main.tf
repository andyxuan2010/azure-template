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
    time = {
      source  = "hashicorp/time"
      version = ">= 0.13, < 1.0"
    }
  }
}

provider "azuread" {}

provider "azurerm" {
  features {}
}

module "application" {
  source = "../.."

  name                     = var.name
  sign_in_audience         = "AzureADMyOrg"
  create_service_principal = true
  create_client_secret     = false

  tags = [
    "environment:dev",
    "managed-by:terraform"
  ]
}
