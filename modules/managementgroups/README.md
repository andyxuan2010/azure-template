# Management Groups Module

Provision an Azure Management Group for landing zone hierarchy composition.

## Overview

- Providers: `azurerm`, `random`
- Use case: enterprise landing zone hierarchy such as `platform`, `corp`, `online`, or workload-specific child groups
- Terraform tests: `tests/live.tftest.hcl`

## Basic Usage

```hcl
module "platform_mg" {
  source = "./modules/managementgroups"

  display_name               = "Platform"
  parent_management_group_id = "/providers/Microsoft.Management/managementGroups/contoso-root"
  subscription_ids           = []
}
```

## Proper Usage

- Create management groups before policy assignment and subscription vending.
- Use a stable `name` if the group becomes a long-lived governance anchor.
- Use `parent_management_group_id` to explicitly attach the group into the target hierarchy.
- Only pass `subscription_ids` when this module is also responsible for immediate subscription placement.

## Common Use Cases

- Platform landing zone hierarchy
- Workload segregation by environment or business unit
- Pre-staging management groups before policy rollouts

## Dependencies

- None required at the resource level beyond tenant permissions
- Common downstream consumers: `policy`, `subscription_vending`

## Testing

```powershell
terraform test -filter='tests\live.tftest.hcl'
```
