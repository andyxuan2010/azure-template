mock_provider "azurerm" {}

variables {
  name              = "FortiGate Route Updater"
  scope             = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network-prod"
  description       = "Read route tables and read, create, or update routes."
  assignable_scopes = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network-prod"]
  actions = [
    "Microsoft.Network/routeTables/read",
    "Microsoft.Network/routeTables/routes/read",
    "Microsoft.Network/routeTables/routes/write",
  ]
}

run "plan_route_updater_role" {
  command = plan

  assert {
    condition     = azurerm_role_definition.this.name == "FortiGate Route Updater"
    error_message = "The role definition should use the requested display name."
  }

  assert {
    condition     = azurerm_role_definition.this.permissions[0].actions == var.actions
    error_message = "The role definition should contain the specified control-plane actions."
  }

  assert {
    condition     = length(azurerm_role_definition.this.permissions[0].data_actions) == 0
    error_message = "The route updater role should not include data-plane permissions."
  }
}

run "reject_assignable_scopes_missing_definition_scope" {
  command = plan

  variables {
    assignable_scopes = ["/subscriptions/00000000-0000-0000-0000-000000000000"]
  }

  expect_failures = [
    var.assignable_scopes,
  ]
}

run "reject_role_without_allowed_permissions" {
  command = plan

  variables {
    actions      = []
    data_actions = []
  }

  expect_failures = [
    check.permissions_configured,
  ]
}
