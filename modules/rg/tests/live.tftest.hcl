provider "azurerm" {
  features {}
}

provider "azuread" {}

variables {
  name            = ""
  location        = "eastus"
  enable_lock     = false
  lock_level      = "CanNotDelete"
  lock_notes      = "Managed by Terraform"
  app_admin_group = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
  app_user_group  = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
  tags = {
    Environment = "Production"
    Owner       = "CCOE"
    IaC         = "Terraform"
  }
}

run "apply" {
  command = apply

  assert {
    condition     = startswith(output.name, "rg-eastus-") && length(output.name) <= 90
    error_message = "Generated resource group name did not follow the expected pattern."
  }

  assert {
    condition     = output.location == var.location
    error_message = "Resource group location output did not match the requested location."
  }

  assert {
    condition     = output.lock_id == null
    error_message = "Lock output should be null when enable_lock is false."
  }

  assert {
    condition     = output.tags.Environment == var.tags.Environment && output.tags.Owner == var.tags.Owner && output.tags.IaC == var.tags.IaC && output.tags.module == "rg"
    error_message = "Effective tags did not include the requested tags plus the module tag."
  }

  assert {
    condition     = length(output.app_admin_group_role_assignment_ids) == length(var.app_admin_group)
    error_message = "Expected one Contributor role assignment per app_admin_group entry."
  }

  assert {
    condition     = length(output.app_user_group_role_assignment_ids) == length(var.app_user_group)
    error_message = "Expected one Reader role assignment per app_user_group entry."
  }
}
