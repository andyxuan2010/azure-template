# Azure Resource Group Module

Provision an Azure Resource Group with standardized naming, environment-aware tags, optional management locks, and flexible role assignments at the resource group scope.

## Highlights

- Supports explicit names or generated names with workload, environment, location code, instance, and optional random suffix segments.
- Applies standardized tags including `ManagedBy`, `module`, `name`, `app_env`, `Environment`, and `CostCenter`.
- Supports optional management locks with custom name, level, and notes.
- Preserves simple `app_admin_group` and `app_user_group` shortcuts while adding arbitrary `role_assignments` for custom RBAC.
- Supports `managed_by` and configurable resource group operation timeouts.
- Uses plan-only Terraform tests for deterministic validation.

## Usage

```hcl
module "rg" {
  source = "./modules/rg"

  name     = "rg-contoso-prod-eus-001"
  location = "eastus"
  app_env  = "prod"

  enable_lock = true
  lock_level  = "CanNotDelete"

  app_admin_group = [
    "00000000-0000-0000-0000-000000000000"
  ]

  role_assignments = {
    monitoring_reader = {
      principal_id         = "11111111-1111-1111-1111-111111111111"
      principal_type       = "Group"
      role_definition_name = "Monitoring Reader"
    }
  }

  tags = {
    Owner = "CCOE"
    IaC   = "Terraform"
  }
}
```

## Operational Notes

- Prefer explicit resource group names for long-lived environments.
- Use `use_random_suffix = false` with `workload_name`, `app_env`, `location_code`, and `instance` when deterministic generated names are required.
- Prefer Entra object IDs over group display names for RBAC inputs when group names may be duplicated.
- Use `ReadOnly` locks carefully because they can block write operations within the resource group.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | >= 3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | 3.8.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.65.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.8.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.app_admin_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.app_user_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [azuread_group.app_admin](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) | data source |
| [azuread_group.app_user](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_admin_group"></a> [app\_admin\_group](#input\_app\_admin\_group) | List of Entra group display names or object IDs that should receive Contributor access to the resource group. Prefer object IDs when display names are not unique. | `list(string)` | `[]` | no |
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Deployment environment used for standard tags and optional generated naming. | `string` | `"dev"` | no |
| <a name="input_app_user_group"></a> [app\_user\_group](#input\_app\_user\_group) | List of Entra group display names or object IDs that should receive Reader access to the resource group. Prefer object IDs when display names are not unique. | `list(string)` | `[]` | no |
| <a name="input_enable_lock"></a> [enable\_lock](#input\_enable\_lock) | Whether to create a management lock on the resource group. | `bool` | `false` | no |
| <a name="input_include_environment_in_name"></a> [include\_environment\_in\_name](#input\_include\_environment\_in\_name) | Whether to include app\_env in generated resource group names. | `bool` | `true` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Optional instance segment used when the resource group name is generated and random suffixes are disabled. | `string` | `"001"` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the resource group will be deployed. | `string` | n/a | yes |
| <a name="input_location_code"></a> [location\_code](#input\_location\_code) | Optional short location code used when the resource group name is generated. When empty, the module derives a code from location. | `string` | `""` | no |
| <a name="input_lock_level"></a> [lock\_level](#input\_lock\_level) | Management lock level when enable\_lock is true. | `string` | `"CanNotDelete"` | no |
| <a name="input_lock_name"></a> [lock\_name](#input\_lock\_name) | Optional management lock name. When empty, the module uses <resource-group-name>-lock. | `string` | `""` | no |
| <a name="input_lock_notes"></a> [lock\_notes](#input\_lock\_notes) | Optional notes to attach to the management lock. | `string` | `""` | no |
| <a name="input_managed_by"></a> [managed\_by](#input\_managed\_by) | Optional resource ID that manages this resource group, typically used by Azure managed applications. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Resource group name. If empty, the module auto-generates a name. | `string` | `""` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix used when the resource group name is generated. | `string` | `"rg"` | no |
| <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments) | Additional role assignments to create at the resource group scope, keyed by a stable name. | <pre>map(object({<br>    principal_id                           = string<br>    role_definition_name                   = optional(string)<br>    role_definition_id                     = optional(string)<br>    principal_type                         = optional(string)<br>    description                            = optional(string)<br>    name                                   = optional(string)<br>    condition                              = optional(string)<br>    condition_version                      = optional(string)<br>    delegated_managed_identity_resource_id = optional(string)<br>    skip_service_principal_aad_check       = optional(bool, false)<br>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource group. | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Optional timeouts for resource group create, read, update, and delete operations. | <pre>object({<br>    create = optional(string)<br>    read   = optional(string)<br>    update = optional(string)<br>    delete = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_use_random_suffix"></a> [use\_random\_suffix](#input\_use\_random\_suffix) | Whether generated names should include a random suffix. Set false for deterministic generated names. | `bool` | `true` | no |
| <a name="input_workload_name"></a> [workload\_name](#input\_workload\_name) | Optional workload or application segment used when the resource group name is generated. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_admin_group_principal_ids"></a> [app\_admin\_group\_principal\_ids](#output\_app\_admin\_group\_principal\_ids) | Map of resolved Contributor group principal IDs keyed by app\_admin\_group input. |
| <a name="output_app_admin_group_role_assignment_ids"></a> [app\_admin\_group\_role\_assignment\_ids](#output\_app\_admin\_group\_role\_assignment\_ids) | Map of Contributor role assignment IDs keyed by app\_admin\_group input. |
| <a name="output_app_env"></a> [app\_env](#output\_app\_env) | The deployment environment used by the module. |
| <a name="output_app_user_group_principal_ids"></a> [app\_user\_group\_principal\_ids](#output\_app\_user\_group\_principal\_ids) | Map of resolved Reader group principal IDs keyed by app\_user\_group input. |
| <a name="output_app_user_group_role_assignment_ids"></a> [app\_user\_group\_role\_assignment\_ids](#output\_app\_user\_group\_role\_assignment\_ids) | Map of Reader role assignment IDs keyed by app\_user\_group input. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the resource group. |
| <a name="output_location"></a> [location](#output\_location) | The location of the resource group. |
| <a name="output_location_code"></a> [location\_code](#output\_location\_code) | The resolved location code used for generated naming. |
| <a name="output_lock_config"></a> [lock\_config](#output\_lock\_config) | Effective management lock configuration. |
| <a name="output_lock_id"></a> [lock\_id](#output\_lock\_id) | The ID of the management lock, if created. |
| <a name="output_managed_by"></a> [managed\_by](#output\_managed\_by) | The managed\_by value configured on the resource group, if any. |
| <a name="output_name"></a> [name](#output\_name) | The name of the resource group. |
| <a name="output_role_assignment_count"></a> [role\_assignment\_count](#output\_role\_assignment\_count) | Total number of role assignments requested by this module. |
| <a name="output_role_assignment_ids"></a> [role\_assignment\_ids](#output\_role\_assignment\_ids) | Map of additional role assignment IDs keyed by role\_assignments input. |
| <a name="output_tags"></a> [tags](#output\_tags) | The effective tags assigned to the resource group. |
<!-- END_TF_DOCS -->
