# Azure Role Assignments

Creates deterministic Azure RBAC assignments at management group, subscription, resource group, or resource scope.

## Features

- Multiple assignments from one stable map
- Direct principal IDs or Microsoft Entra group display-name resolution
- Direct role definition IDs or Azure role name resolution
- Optional principal type and Azure RBAC conditions
- Deterministic role assignment GUIDs
- Rejection of ambiguous selectors, incomplete conditions, and duplicate logical assignments

## Resources Created

The module creates `azurerm_role_assignment` resources only. It performs optional data lookups for Entra groups and Azure role definitions.

It does not create identities, groups, custom role definitions, Privileged Identity Management assignments, or deny assignments.

## Prerequisites and Dependencies

- Existing target scopes
- Existing principals and role definitions
- Azure RBAC permission to create assignments at every requested scope
- Microsoft Entra directory read permission for group-name lookup
- A single Terraform owner or import plan for existing assignments

## Provider Configuration

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.0, < 4.0"
    }
  }
}
```

## Basic Usage

```hcl
module "role_assignments" {
  source = "./modules/roleassignments"

  assignments = {
    application_reader = {
      scope                = module.rg.id
      role_definition_name = "Reader"
      principal_id         = var.application_group_object_id
      principal_type       = "Group"
    }
  }
}
```

See [examples/basic](./examples/basic), [examples/complete](./examples/complete), and [examples/conditional](./examples/conditional).

## Selector Rules

Every assignment must provide exactly one of:

- `role_definition_name` or `role_definition_id`
- `principal_name` or `principal_id`

`principal_name` resolves an Entra group only. Use IDs for users, service principals, managed identities, devices, foreign groups, duplicated group names, and cross-tenant principals.

Conditions require both `condition` and `condition_version = "2.0"`.

## Idempotency and Existing Assignments

The module derives the Azure assignment GUID from normalized scope, resolved role ID, resolved principal ID, principal type, and condition values. Duplicate logical assignments in one module input are rejected.

Terraform state provides idempotency for assignments it already owns. The module does not query, skip, or adopt matching assignments that exist outside the current state. Import those assignments before apply or remove the competing owner.

See [Idempotency](./docs/idempotency.md) for the full lifecycle model.

## Important Behavior and Secure Defaults

- The module grants access, so every assignment is a security change. There are no default assignments and no default scopes; each entry must name its own `scope`, role, and principal, and nothing is assigned broadly unless the caller asks for it.
- Each assignment name is a deterministic GUID derived from the lower-cased scope, resolved role definition ID, resolved principal ID, principal type, and condition. Changing any of those produces a different GUID, so Azure sees a new assignment and the old one is removed. Renaming a map key alone changes the Terraform address, not the GUID; use a `moved` block to avoid a destroy and create.
- Every assignment sets `role_definition_id`, never `role_definition_name`: role names are resolved to IDs with a data lookup at the assignment's own `scope`. Exactly one of role name or ID, and exactly one of `principal_name` or `principal_id`, is required; conditions need both `condition` and `condition_version`.
- Azure Policy and RBAC guardrails (for example restrictions on who may create assignments or which roles may be granted) can reject an assignment at apply time even when the plan is valid. Assignments that already exist outside state are not adopted and fail on creation; import them first.
- Lookups by role name or group display name use data sources. When the scope, principal, or role comes from a resource not yet created, those lookups are deferred and the resolved IDs are unknown until apply. Duplicate logical assignments are rejected by a resource `precondition`, which Terraform evaluates once the lookups are known, so a duplicate can surface during apply rather than at plan.


## Naming and Tagging

Role assignments do not support ARM tags, and the module has no `name` or `tags` input. It names nothing the caller can set: each assignment's name is the deterministic GUID described above. The caller controls everything else through the `assignments` map: the map key is only the Terraform address, and `scope`, role, principal, `principal_type`, and condition define the assignment. Names of the scoped resources, groups, and identities are owned by the modules or tenants that create them.

Follow the repository [naming convention](../../docs/60-security-governance/naming-convention.md) and [tagging standard](../../docs/60-security-governance/tagging-standard.md).


## Testing

```powershell
terraform init -backend=false
terraform test -filter=tests/unit.tftest.hcl
```

Tests use mocked AzureRM and AzureAD providers and do not change Azure RBAC.

## Known Limitations

- Principal name lookup supports Entra groups only.
- Existing assignments outside Terraform state are not detected or adopted.
- Custom role definitions must already exist.
- Azure validates authorization, propagation, assignable scopes, principal existence, and condition syntax at apply time.
- PIM-eligible assignments and access reviews are outside the module.

## Terraform Reference

The content below is generated by `terraform-docs`. Do not edit it manually.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | >= 3.0, < 4.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0, < 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | >= 3.0, < 4.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0, < 5.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assignments"></a> [assignments](#input\_assignments) | Role assignments keyed by assignment name. | <pre>map(object({<br>    scope                = string<br>    role_definition_name = optional(string)<br>    role_definition_id   = optional(string)<br>    principal_id         = optional(string)<br>    principal_name       = optional(string)<br>    principal_type       = optional(string)<br>    condition            = optional(string)<br>    condition_version    = optional(string)<br>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_role_assignment_ids"></a> [role\_assignment\_ids](#output\_role\_assignment\_ids) | Role assignment IDs keyed by assignment name. |
<!-- END_TF_DOCS -->
