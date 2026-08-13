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
  add_current_caller_as_owner  = true
  app_role_assignment_required = false
  description                  = "Terraform-managed Enterprise Application."
}
