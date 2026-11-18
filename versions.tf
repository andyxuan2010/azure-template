terraform {
  required_version = ">= 1.7.0, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }

    azapi = {
      source  = "Azure/azapi"
      version = ">= 2.0, < 3.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.0, < 4.0"
    }

    msgraph = {
      source  = "microsoft/msgraph"
      version = ">= 0.3, < 0.6"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.0, < 4.0"
    }
  }
}
