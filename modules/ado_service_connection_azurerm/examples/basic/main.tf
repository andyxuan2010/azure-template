terraform {
  required_version = ">= 1.7.0, < 2.0.0"
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">= 1.15.0, < 2.0.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
  }
}
provider "azuredevops" {
  org_service_url = var.organization_url
  # Supply authentication through the provider's supported environment settings.
}
provider "azurerm" {
  features {}
  subscription_id = split("/", var.managed_identity.id)[2]
}

module "example" {
  source                    = "../.."
  project_id                = var.project_id
  name                      = var.name
  description               = var.description
  managed_identity          = var.managed_identity
  subscription_name         = var.subscription_name
  pipeline_ids              = var.pipeline_ids
  federated_credential_name = var.federated_credential_name
  subscription_id           = var.subscription_id
}
