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
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

module "web_app" {
  source = "../.."

  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  app_service_plan_id           = var.app_service_plan_id
  inherit_resource_group_tags   = false
  inherited_resource_group_tags = {}

  system_assigned_identity_enabled = true
  active_directory_client_id       = var.active_directory_client_id
  auth_mode                        = "easy_auth"
  allow_anonymous                  = false
  ip_restriction_default_action    = "Allow"

  app_settings = {
    MICROSOFT_PROVIDER_AUTHENTICATION_SECRET = "@Microsoft.KeyVault(SecretUri=${var.client_secret_key_vault_uri})"
  }
}
