mock_provider "azurerm" {}

variables {
  subscription_name        = "platform-prod"
  existing_subscription_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
  management_group_id      = "/providers/Microsoft.Management/managementGroups/platform"
  resource_provider_registrations = [
    "Microsoft.KeyVault",
    "Microsoft.Network"
  ]
  bootstrap_resource_groups = {
    monitoring = {
      name     = "rg-platform-monitoring-prod"
      location = "canadacentral"
      tags = {
        Purpose = "Monitoring"
      }
    }
  }
  tags = {
    Owner = "Platform"
  }
}

run "plan_existing_subscription_bootstrap" {
  command = plan

  assert {
    condition     = output.subscription_id == "/subscriptions/00000000-0000-0000-0000-000000000000"
    error_message = "The existing subscription ID was not normalized."
  }

  assert {
    condition     = length(azurerm_management_group_subscription_association.this) == 1
    error_message = "The management-group association was not planned."
  }

  assert {
    condition     = length(azurerm_resource_provider_registration.this) == 2
    error_message = "Expected two resource-provider registrations."
  }

  assert {
    condition     = azurerm_resource_group.bootstrap["monitoring"].tags.Owner == "Platform" && azurerm_resource_group.bootstrap["monitoring"].tags.Purpose == "Monitoring"
    error_message = "Bootstrap resource-group tags were not merged correctly."
  }
}

run "plan_without_management_group" {
  command = plan

  variables {
    enable_management_group_association = false
    management_group_id                 = ""
  }

  assert {
    condition     = length(azurerm_management_group_subscription_association.this) == 0
    error_message = "No management-group association should be created when disabled."
  }
}
