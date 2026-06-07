terraform {
  required_version = ">= 1.0"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.0"
    }
    msgraph = {
      source  = "microsoft/msgraph"
      version = ">= 0.3"
    }
  }
}

provider "azuread" {}

provider "msgraph" {}

module "appregistration" {
  source = "../../../appregistration"

  display_name             = var.display_name
  create_service_principal = false

  web_homepage_url = var.homepage_url
  web_redirect_uris = [
    "${var.homepage_url}/signin-oidc"
  ]

  tags = [
    "env:${var.app_env}",
    "iac:terraform",
    "module:appregistration"
  ]
}

module "enterpriseapplication" {
  source = "../.."

  application_id                = module.appregistration.application_id
  account_enabled               = true
  app_role_assignment_required  = var.app_role_assignment_required
  description                   = "Enterprise Application for ${var.display_name}"
  login_url                     = var.homepage_url
  preferred_single_sign_on_mode = "oidc"
  notification_email_addresses  = var.notification_email_addresses

  create_application_proxy = var.create_application_proxy
  application_proxy        = var.create_application_proxy ? var.application_proxy : null
}
