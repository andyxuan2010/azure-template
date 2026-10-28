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

module "github_workload_identity" {
  source = "../.."

  name                     = var.name
  create_service_principal = false
  create_client_secret     = false

  federated_identity_credentials = {
    github_main = {
      display_name = "github-main"
      issuer       = "https://token.actions.githubusercontent.com"
      subject      = "repo:${var.github_organization}/${var.github_repository}:ref:refs/heads/main"
      description  = "GitHub Actions on the protected main branch."
    }
  }

  tags = [
    "authentication:workload-identity",
    "managed-by:terraform"
  ]
}
