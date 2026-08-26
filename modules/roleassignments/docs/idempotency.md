# Role Assignment Idempotency

## Desired Identity

For each input entry, the module:

1. Normalizes whitespace.
2. Resolves a role name to its role definition ID when needed.
3. Resolves an Entra group display name to its object ID when needed.
4. Builds a deterministic UUID from scope, resolved role, resolved principal, principal type, and condition values.
5. Creates one Terraform-managed Azure role assignment.

Stable map keys keep Terraform resource addresses stable. Stable resolved values keep the Azure assignment GUID stable.

## Duplicate Inputs

Two map entries that resolve to the same deterministic assignment name are rejected by a resource precondition before Azure RBAC creation. If role or principal lookups are deferred, Terraform evaluates this precondition once those values are known during apply.

Principal type and condition values participate in the deterministic identity. Keep these values consistent across callers and avoid describing the same Azure access grant from different stacks.

## Existing Azure Assignments

The module does not enumerate Azure role assignments during planning. A matching assignment outside the current Terraform state is therefore not skipped or adopted automatically.

Use one of these approaches:

- Import the existing assignment into the intended module address.
- Remove the assignment from the competing owner before apply.
- Leave the existing owner authoritative and omit it from this module.

Example:

```powershell
terraform import `
  'module.role_assignments.azurerm_role_assignment.this["application_reader"]' `
  '/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleAssignments/11111111-1111-1111-1111-111111111111'
```

## Unknown Scopes

The design does not require an Azure-side lookup of existing assignments, so a scope produced by another resource in the same apply can remain unknown during planning. Role and principal name lookups still require their referenced objects to exist and be readable.

## Operational Guidance

- Prefer principal and role definition IDs for stable, unambiguous automation.
- Import before apply when adopting existing RBAC.
- Keep one state authoritative for each logical assignment.
- Review broad management group and subscription assignments as high-impact access changes.
- Allow for Azure RBAC propagation delay after creation.
