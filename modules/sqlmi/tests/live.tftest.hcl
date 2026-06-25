mock_provider "azurerm" {}

mock_provider "azuread" {}

variables {
  name                          = "sqlmi-platform-dev-001"
  resource_group_name           = "rg-platform-dev"
  location                      = "canadacentral"
  inherited_resource_group_tags = {}
  subnet_id                     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-platform/subnets/snet-sqlmi"
  administrator_login           = "sqladminuser"
  administrator_login_password  = "Terraform-Test-Password-123!"
  sku_name                      = "GP_Gen5"
  vcores                        = 8
  storage_size_in_gb            = 512

  tags = {
    Owner = "CCOE"
  }
}

run "plan_managed_instance_defaults" {
  command = plan

  assert {
    condition     = output.name == var.name && output.location == var.location && output.subnet_id == var.subnet_id
    error_message = "SQL Managed Instance core inputs were not propagated."
  }

  assert {
    condition     = output.tags.Owner == "CCOE" && !contains(keys(output.tags), "Environment")
    error_message = "SQL Managed Instance must preserve caller tags without generating implicit tags."
  }
}

run "plan_diagnostics_entra_and_rbac" {
  command = plan

  variables {
    enable_diagnostics         = true
    log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-monitor/providers/Microsoft.OperationalInsights/workspaces/log-platform"
    app_admin_group            = ["11111111-1111-1111-1111-111111111111"]
    app_user_group             = ["22222222-2222-2222-2222-222222222222"]
    azure_active_directory_administrator = {
      login_username = "sql-admins"
      object_id      = "33333333-3333-3333-3333-333333333333"
      principal_type = "Group"
    }
  }

  assert {
    condition     = length(azurerm_monitor_diagnostic_setting.this) == 1 && length(output.app_admin_group_role_assignment_ids) == 1 && length(output.app_user_group_role_assignment_ids) == 1
    error_message = "Diagnostics and RBAC should be planned when enabled."
  }
}

run "plan_user_assigned_identity" {
  command = plan

  variables {
    identity_type = "UserAssigned"
    identity_ids = [
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-identity/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-sqlmi"
    ]
  }
}

run "reject_missing_user_assigned_identity" {
  command = plan

  variables {
    identity_type = "UserAssigned"
    identity_ids  = []
  }

  expect_failures = [
    check.sqlmi_input_consistency,
  ]
}

run "reject_invalid_storage_increment" {
  command = plan

  variables {
    storage_size_in_gb = 100
  }

  expect_failures = [
    var.storage_size_in_gb,
  ]
}
