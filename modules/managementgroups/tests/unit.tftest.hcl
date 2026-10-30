mock_provider "azurerm" {}

mock_provider "random" {}

variables {
  display_name               = "Platform Landing Zone"
  name                       = "platform"
  parent_management_group_id = "/providers/Microsoft.Management/managementGroups/contoso-root"
  subscription_ids = [
    "11111111-1111-1111-1111-111111111111"
  ]
  tags = {
    Owner = "CCOE"
  }
}

run "plan_named_management_group" {
  command = plan

  assert {
    condition     = output.name == var.name && output.display_name == var.display_name
    error_message = "Management group name or display name was not propagated."
  }

  assert {
    condition     = output.tags.Owner == "CCOE"
    error_message = "Management group metadata tags were not preserved."
  }
}

run "reject_duplicate_subscriptions" {
  command = plan

  variables {
    subscription_ids = [
      "11111111-1111-1111-1111-111111111111",
      "11111111-1111-1111-1111-111111111111"
    ]
  }

  expect_failures = [
    var.subscription_ids,
  ]
}
