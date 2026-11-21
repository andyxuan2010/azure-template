mock_provider "azurerm" {}
mock_provider "azuread" {}
mock_provider "random" {}

variables {
  name            = "rg-iactest-prod-001"
  location        = "canadacentral"
  app_env         = "prod"
  enable_lock     = false
  app_admin_group = []
  app_user_group  = []

  tags = {
    Environment = "Production"
    Owner       = "CCOE"
    IaC         = "Terraform"
  }
}

run "plan_named_resource_group" {
  command = plan

  assert {
    condition     = output.name == var.name
    error_message = "Resource group name output did not match the requested name."
  }

  assert {
    condition     = output.location == var.location
    error_message = "Resource group location output did not match the requested location."
  }

  assert {
    condition     = output.tags.Environment == "Production" && !contains(keys(output.tags), "ManagedBy") && !contains(keys(output.tags), "module")
    error_message = "Resource group tags should be caller-controlled without module-generated marker tags."
  }

  assert {
    condition     = output.lock_config.enabled == false && output.lock_id == null
    error_message = "Lock output should be disabled and null when enable_lock is false."
  }
}

run "plan_generated_name_without_random" {
  command = plan

  variables {
    name                        = ""
    name_prefix                 = "rg"
    workload_name               = "shared"
    app_env                     = "poc"
    include_environment_in_name = true
    location                    = "canadacentral"
    location_code               = "cc"
    instance                    = "001"
    use_random_suffix           = false
    app_admin_group             = []
    app_user_group              = []
  }

  assert {
    condition     = output.name == "rg-shared-poc-cc-001"
    error_message = "Generated deterministic resource group name did not match the expected naming convention."
  }

  assert {
    condition     = output.location_code == "cc"
    error_message = "Location code output did not use the explicit override."
  }
}

run "plan_lock_and_custom_roles" {
  command = plan

  variables {
    name            = "rg-iactest-prod-roles"
    location        = "canadacentral"
    app_env         = "prod"
    enable_lock     = true
    lock_name       = "rg-iactest-prod-roles-delete-lock"
    lock_level      = "CanNotDelete"
    lock_notes      = "Protected by Terraform"
    app_admin_group = ["11111111-1111-1111-1111-111111111111"]
    app_user_group  = ["22222222-2222-2222-2222-222222222222"]

    role_assignments = {
      monitoring_reader = {
        principal_id         = "33333333-3333-3333-3333-333333333333"
        principal_type       = "Group"
        role_definition_name = "Monitoring Reader"
        description          = "Read monitoring data at the resource group scope."
      }
    }
  }

  assert {
    condition     = output.lock_config.enabled == true && output.lock_config.name == "rg-iactest-prod-roles-delete-lock"
    error_message = "Lock configuration output did not reflect the requested lock."
  }

  assert {
    condition     = output.role_assignment_count == 3
    error_message = "Role assignment count should include app_admin_group, app_user_group, and additional role_assignments."
  }

  assert {
    condition     = output.app_admin_group_principal_ids["id:11111111-1111-1111-1111-111111111111"] == "11111111-1111-1111-1111-111111111111"
    error_message = "Admin group object ID was not resolved as a direct principal ID."
  }
}

run "plan_managed_by_and_timeouts" {
  command = plan

  variables {
    name       = "rg-iactest-dev-managed"
    location   = "canadacentral"
    app_env    = "dev"
    managed_by = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-managed-app/providers/Microsoft.Solutions/applications/app-managed"
    tags = {
      Environment = "Development"
    }
    app_admin_group = []
    app_user_group  = []

    timeouts = {
      create = "30m"
      read   = "5m"
      update = "30m"
      delete = "30m"
    }
  }

  assert {
    condition     = output.app_env == "dev" && output.tags.Environment == "Development"
    error_message = "Development environment tags were not applied."
  }

  assert {
    condition     = output.location_code == "cc"
    error_message = "Derived location code for canadacentral should be cc."
  }
}

run "reject_ambiguous_role_definition" {
  command = plan

  variables {
    role_assignments = {
      invalid = {
        principal_id         = "33333333-3333-3333-3333-333333333333"
        role_definition_name = "Reader"
        role_definition_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/11111111-1111-1111-1111-111111111111"
      }
    }
  }

  expect_failures = [
    var.role_assignments,
  ]
}
