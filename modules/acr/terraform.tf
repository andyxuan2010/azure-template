terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = ">= 4.0, < 5.0"
      configuration_aliases = [azurerm.prod]
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
