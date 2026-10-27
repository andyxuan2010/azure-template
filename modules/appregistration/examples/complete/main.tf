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

  name                           = var.name
  description                    = "Orders API and web sign-in application."
  sign_in_audience               = "AzureADMyOrg"
  create_service_principal       = true
  create_client_secret           = false
  prevent_duplicate_names        = true
  add_current_caller_as_owner    = true
  requested_access_token_version = 2
  identifier_uris                = ["api://${var.name}"]
  app_service_redirect_hostnames = var.app_service_hostnames
  app_service_auth_mode          = "both"
  web_redirect_uris              = var.additional_web_redirect_uris
  group_membership_claims        = ["ApplicationGroup"]

  app_roles = [
    {
      id                   = "11111111-1111-4111-8111-111111111111"
      value                = "Orders.Read.All"
      display_name         = "Read all orders"
      description          = "Allows an application to read all orders."
      allowed_member_types = ["Application"]
    }
  ]

  oauth2_permission_scopes = [
    {
      id                         = "22222222-2222-4222-8222-222222222222"
      value                      = "Orders.Read"
      admin_consent_display_name = "Read orders"
      admin_consent_description  = "Allows the application to read orders for the signed-in user."
      user_consent_display_name  = "Read your orders"
      user_consent_description   = "Allows the application to read your orders."
      type                       = "User"
    }
  ]

  pre_authorized_applications = {
    web_client = {
      authorized_client_id = var.pre_authorized_client_id
      permission_ids       = ["22222222-2222-4222-8222-222222222222"]
    }
  }

  optional_claims = {
    id_token = [
      {
        name = "email"
      }
    ]
  }

  tags = [
    "environment:prod",
    "managed-by:terraform",
    "owner:platform"
  ]
}
