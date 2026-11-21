mock_provider "azuread" {}

variables {
  groups = {
    static = {
      display_name = "Devices - Static"
      description  = "Static targeting group"
    }
    dynamic = {
      display_name    = "Devices - Windows"
      description     = "Dynamic targeting group"
      membership_rule = "(device.deviceOSType -eq \"Windows\")"
    }
  }
}

run "plan_group_defaults_and_dynamic_membership" {
  command = plan

  assert {
    condition     = azuread_group.this["static"].security_enabled && !azuread_group.this["static"].mail_enabled
    error_message = "Groups must be security-enabled and mail-disabled."
  }

  assert {
    condition     = azuread_group.this["dynamic"].types == ["DynamicMembership"] && azuread_group.this["dynamic"].dynamic_membership[0].enabled
    error_message = "A membership rule must enable dynamic membership."
  }
}
