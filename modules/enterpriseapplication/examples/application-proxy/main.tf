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

provider "azuread" {}

provider "msgraph" {}

module "enterprise_application" {
  source = "../.."

  application_id               = var.application_id
  use_existing                 = true
  app_role_assignment_required = true

  create_application_proxy = true
  application_proxy = {
    internal_url                              = var.internal_url
    external_url                              = var.external_url
    external_authentication_type              = "aadPreAuthentication"
    is_backend_certificate_validation_enabled = true
    is_http_only_cookie_enabled               = true
    is_secure_cookie_enabled                  = true
    is_persistent_cookie_enabled              = false
    is_continuous_access_evaluation_enabled   = true
  }
}
