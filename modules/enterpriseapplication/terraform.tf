terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.0, < 4.0"
    }
    msgraph = {
      source  = "microsoft/msgraph"
      version = ">= 0.3, < 1.0"
    }
  }
}
