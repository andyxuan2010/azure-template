provider "azurerm" {
  features {}
}

variables {
  subscription_name        = "platform-dev"
  existing_subscription_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
  management_group_id      = "/providers/Microsoft.Management/managementGroups/platform"
  resource_provider_registrations = [
    "Microsoft.Network",
    "Microsoft.KeyVault"
  ]
  bootstrap_resource_groups = {}
}

run "plan" {
  command = plan
}
