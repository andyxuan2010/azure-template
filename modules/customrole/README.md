# Azure Custom Role Definition

Creates an Azure RBAC custom role definition with explicit control-plane and data-plane permissions and assignable scopes.

## Features

- Supports management group, subscription, resource group, or resource-level definition scopes.
- Accepts control-plane and data-plane allowed and excluded operations.
- Supports explicit stable role definition GUIDs.
- Exposes the Azure role resource ID for use by role assignment modules.

## Resources Created

Creates one `azurerm_role_definition`. It does not create role assignments, principals, groups, or identities.

## Prerequisites and Dependencies

- The role definition scope and assignable scopes must exist.
- The Terraform identity needs Azure RBAC permissions to create and update custom role definitions at the selected scope. Azure commonly requires `Microsoft.Authorization/roleDefinitions/write` and read access at the scope.
- Custom roles are tenant-visible only within the applicable Azure hierarchy. Azure validates operations, scope relationships, and authorization when applying.

## Provider Configuration

The module requires AzureRM 4.x and does not configure a provider. Configure AzureRM in the calling root module with the target tenant and subscription context.

## Basic Usage

```hcl
module "route_updater_role" {
  source = "./modules/customrole"

  name              = "FortiGate Route Updater"
  scope             = var.resource_group_id
  assignable_scopes = [var.resource_group_id]
  description       = "Read route tables and read, create, or update routes; no route deletion or RBAC management."

  actions = [
    "Microsoft.Network/routeTables/read",
    "Microsoft.Network/routeTables/routes/read",
    "Microsoft.Network/routeTables/routes/write",
  ]
}
```

See [examples/basic](./examples/basic) for an executable example. Use `module.route_updater_role.role_definition_resource_id` as `role_definition_id` in the [roleassignments module](../roleassignments/README.md).

## Important Behavior and Secure Defaults

- The module requires at least one allowed `actions` or `data_actions` entry; it does not add wildcard permissions.
- Azure RBAC `not_actions` and `not_data_actions` are exclusions from the matching allowed set, not explicit deny rules. A different role assignment may still grant excluded operations.
- Keep `actions` and `data_actions` limited to the required operations. Confirm operation names against the Azure provider operations for the target service.
- Include `scope` in `assignable_scopes`. Azure recommends using the first assignable scope as the role definition scope.
- Set `role_definition_id` when a stable GUID is needed across state recreation or environments; Azure generates one when omitted.
- Changing the definition scope or role GUID forces replacement. Azure may take time to propagate role definition changes.

## Identity and RBAC

This module creates the role definition only. It does not grant permissions to any principal. Assign the resulting role at a permitted scope with `roleassignments`, passing the output `role_definition_resource_id`. Assignment scope must be within the role's `assignable_scopes`.

For the route updater example, the role grants only route table read, route read, and route write actions. It does not grant route deletion, network topology changes, role definition changes, or role assignments.

## Naming and Tagging

Azure custom role definitions do not support ARM tags. `name` is the role's display name and should be kept stable; use a stable `role_definition_id` when callers depend on the role GUID. See the repository [naming convention](../../docs/60-security-governance/naming-convention.md) and [tagging standard](../../docs/60-security-governance/tagging-standard.md).

## Testing

`tests/unit.tftest.hcl` uses a mocked AzureRM provider and plan-only runs; it does not authenticate to Azure or create cloud resources. Run:

```powershell
terraform init -backend=false
terraform test -filter=tests/unit.tftest.hcl
```

## Known Limitations

- Azure validates operation names, assignable scopes, role definition uniqueness, and caller permissions at apply time.
- Custom role definition changes can take time to propagate to role assignments.
- `not_actions` and `not_data_actions` do not create deny assignments.
- This module does not create role assignments; use the separate `roleassignments` module.

## Terraform Reference

The content below is generated from the module source. Do not edit it manually.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0, < 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0, < 5.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_role_definition.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_actions"></a> [actions](#input\_actions) | Allowed Azure control-plane actions for the role. | `list(string)` | `[]` | no |
| <a name="input_assignable_scopes"></a> [assignable\_scopes](#input\_assignable\_scopes) | Scopes where this role may be assigned. Include the role definition scope. | `list(string)` | n/a | yes |
| <a name="input_data_actions"></a> [data\_actions](#input\_data\_actions) | Allowed Azure data-plane actions for the role. | `list(string)` | `[]` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the permissions and intended use of the custom role. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Display name of the custom role definition. | `string` | n/a | yes |
| <a name="input_not_actions"></a> [not\_actions](#input\_not\_actions) | Control-plane actions excluded from actions. | `list(string)` | `[]` | no |
| <a name="input_not_data_actions"></a> [not\_data\_actions](#input\_not\_data\_actions) | Data-plane actions excluded from data\_actions. | `list(string)` | `[]` | no |
| <a name="input_role_definition_id"></a> [role\_definition\_id](#input\_role\_definition\_id) | Optional stable UUID/GUID for the role definition. Azure generates one when omitted. | `string` | `null` | no |
| <a name="input_scope"></a> [scope](#input\_scope) | Management group, subscription, resource group, or resource ID where the role definition is managed. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | Terraform resource ID for the custom role definition, formatted as role GUID and scope. |
| <a name="output_name"></a> [name](#output\_name) | Display name of the custom role definition. |
| <a name="output_role_definition_id"></a> [role\_definition\_id](#output\_role\_definition\_id) | UUID/GUID identifying the custom role definition. |
| <a name="output_role_definition_resource_id"></a> [role\_definition\_resource\_id](#output\_role\_definition\_resource\_id) | Azure Resource Manager resource ID for assigning this custom role. |
<!-- END_TF_DOCS -->
