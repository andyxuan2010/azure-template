mock_provider "azurerm" {}

mock_provider "azuread" {}

variables {
  assignments = {
    direct = {
      scope              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-platform"
      role_definition_id = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/11111111-1111-1111-1111-111111111111"
      principal_id       = "22222222-2222-2222-2222-222222222222"
      principal_type     = "Group"
    }
    resolved = {
      scope                = "/subscriptions/00000000-0000-0000-0000-000000000000"
      role_definition_name = "Reader"
      principal_name       = "platform-readers"
    }
  }
}

run "plan_direct_and_resolved_assignments" {
  command = plan

  assert {
    condition     = length(output.role_assignment_ids) == 2
    error_message = "Expected both direct-ID and name-resolved role assignments."
  }
}

run "reject_ambiguous_role_definition" {
  command = plan

  variables {
    assignments = {
      invalid = {
        scope                = "/subscriptions/00000000-0000-0000-0000-000000000000"
        role_definition_name = "Reader"
        role_definition_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/11111111-1111-1111-1111-111111111111"
        principal_id         = "22222222-2222-2222-2222-222222222222"
      }
    }
  }

  expect_failures = [
    check.role_assignments_consistency,
  ]
}

run "reject_incomplete_condition" {
  command = plan

  variables {
    assignments = {
      invalid = {
        scope                = "/subscriptions/00000000-0000-0000-0000-000000000000"
        role_definition_name = "Reader"
        principal_id         = "22222222-2222-2222-2222-222222222222"
        condition            = "@Resource[Microsoft.Storage/storageAccounts/blobServices/containers:name] StringEqualsIgnoreCase 'logs'"
      }
    }
  }

  expect_failures = [
    check.role_assignments_consistency,
  ]
}
