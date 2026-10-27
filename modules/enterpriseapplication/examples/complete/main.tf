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

provider "msgraph" {}

provider "azurerm" {
  features {}
}

module "app_registration" {
  source = "../../../appregistration"

  name                     = var.display_name
  create_service_principal = false
  web_homepage_url         = var.homepage_url
  web_redirect_uris        = ["${var.homepage_url}/signin-oidc"]

  tags = [
    "env:${var.environment}",
    "iac:terraform"
  ]
}

module "enterprise_application" {
  source = "../.."

  application_id                = module.app_registration.application_id
  use_existing                  = true
  account_enabled               = true
  add_current_caller_as_owner   = true
  app_role_assignment_required  = true
  description                   = "Enterprise Application for ${var.display_name}"
  login_url                     = var.homepage_url
  preferred_single_sign_on_mode = "oidc"
  notification_email_addresses  = var.notification_email_addresses
}
