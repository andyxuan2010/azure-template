mock_provider "azurerm" {}

variables {
  name         = "require-tag-owner"
  display_name = "Require Owner Tag"
  policy_rule = jsonencode({
    if = {
      field  = "tags['Owner']"
      exists = "false"
    }
    then = {
      effect = "audit"
    }
  })
  parameters        = "{}"
  metadata          = jsonencode({ category = "Tags" })
  create_assignment = false
}

run "plan" {
  command = plan

  assert {
    condition     = output.assignment_id == null
    error_message = "No assignment should be created by the definition-only scenario."
  }
}

run "plan_resource_group_assignment" {
  command = plan

  variables {
    create_assignment = true
    assignment_scope  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-platform-prod"
    assignment_metadata = jsonencode({
      category = "Tags"
    })
    assignment_not_scopes = [
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-platform-prod/providers/Microsoft.Resources/deployments/excluded"
    ]
    non_compliance_messages = [
      {
        content = "Resources must include the Owner tag."
      }
    ]
    identity_type = "SystemAssigned"
    location      = "canadacentral"
  }

  assert {
    condition     = output.assignment_scope_kind == "resource_group"
    error_message = "The assignment scope should resolve to resource_group."
  }

  assert {
    condition     = length(azurerm_resource_group_policy_assignment.this) == 1
    error_message = "One resource group policy assignment should be planned."
  }
}
