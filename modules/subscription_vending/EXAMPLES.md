# Examples

## Existing Subscription Bootstrap

Use an existing subscription, move it under the target management group, register core providers, and create bootstrap resource groups.

```hcl
provider "azurerm" {
  alias           = "vend"
  subscription_id = "00000000-0000-0000-0000-000000000000"
  features {}
}

module "subscription_vending" {
  source = "./modules/subscription_vending"
  providers = {
    azurerm = azurerm.vend
  }

  subscription_name        = "platform-prod"
  existing_subscription_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
  management_group_id      = "/providers/Microsoft.Management/managementGroups/platform"

  resource_provider_registrations = [
    "Microsoft.KeyVault",
    "Microsoft.Network",
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
```

For a new subscription, apply alias creation first, then configure the provider for the returned subscription ID and perform bootstrap in a second stage.
