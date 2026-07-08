# Policy Module

Provision a custom Azure Policy definition and optionally assign it at management group, subscription, or resource group scope.

## Overview

- Providers: `azurerm`
- Use case: governance baseline, landing zone guardrails, tagging standards, public access restrictions
- Terraform tests: `tests/live.tftest.hcl`
- Supports assignment metadata, excluded scopes, non-compliance messages, managed identity, and assignment timeouts.
- Tests use a mocked provider and deploy no Azure resources.

## Basic Usage

```hcl
module "deny_public_ip_policy" {
  source = "./modules/policy"

  name         = "deny-public-ip"
  display_name = "Deny Public IP"
  policy_rule  = jsonencode({
    if = {
      field  = "type"
      equals = "Microsoft.Network/publicIPAddresses"
    }
    then = {
      effect = "deny"
    }
  })
}
```

## Proper Usage

- Define policy close to the intended governance scope, usually at management group level.
- Use `create_assignment = true` only when the module should own both the definition and assignment lifecycle.
- Prefer management group assignments for enterprise landing zones and resource group assignments for application-specific controls.
- Use `assignment_not_scopes` sparingly and document exclusions with `non_compliance_messages`.

## Dependencies

- Optional upstream dependency: `managementgroups`
- Common downstream consumers: workload subscriptions and resource groups

## Testing

```powershell
terraform test -filter='tests\live.tftest.hcl'
```
