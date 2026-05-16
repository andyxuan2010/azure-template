terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.8"
    }
    time = {
      source = "hashicorp/time"
    }
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}
