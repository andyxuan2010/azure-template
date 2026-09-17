# Azure Subscription Vending

Creates a new Azure subscription alias or bootstraps an existing subscription with management-group placement, resource-provider registrations, resource groups, and common tags.

## Features

- Creates a subscription alias under a Microsoft Customer Agreement billing scope.
- Targets an existing subscription when alias creation is disabled.
- Associates the target subscription with a management group.
- Registers an explicit set of Azure resource providers.
- Creates tagged bootstrap resource groups.
- Exposes the normalized subscription resource ID for downstream composition.

## Resources Created

A subscription alias is created only in new-subscription mode. Management-group association, resource-provider registrations, and bootstrap resource groups are independently conditional.

Billing scopes, management groups, and existing subscriptions are referenced but not managed. See [architecture](docs/architecture.md) for the required two-stage new-subscription workflow.

## Prerequisites and Dependencies

- A Microsoft Customer Agreement billing scope and permission to create subscription aliases when vending a new subscription
- An existing subscription resource ID when bootstrapping only
- Management-group write access when association is enabled
- An AzureRM provider configured for the subscription where providers and resource groups will be created
- Organization-approved resource-provider and bootstrap resource-group definitions

## Provider Configuration

The module requires AzureRM 4.x. Provider configuration is the critical lifecycle boundary: Terraform cannot dynamically reconfigure a provider with the subscription ID produced by the same module call.

For an existing subscription, pass an AzureRM provider configured for that subscription. For a new subscription, apply alias creation first, configure a provider for the returned subscription, and perform bootstrap in a second state or stage.

## Basic Usage

```hcl
module "subscription_vending" {
  source = "./modules/subscription_vending"

  providers = {
    azurerm = azurerm.vend
  }

  existing_subscription_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
  management_group_id      = "/providers/Microsoft.Management/managementGroups/platform"
}
```

The complete executable configuration is in [`examples/basic`](examples/basic/).

## Important Behavior and Secure Defaults

- Existing-subscription mode requires a full `/subscriptions/<guid>` resource ID.
- New-subscription mode requires both `subscription_alias_name` and `billing_scope_id`.
- Management-group association is enabled by default and requires `management_group_id`.
- No resource providers or bootstrap resource groups are created unless explicitly supplied.
- Removing a provider registration or bootstrap resource group from configuration can cause an unregister or destroy action. Review downstream dependencies before applying.
- Subscription creation and management-group moves are governance-sensitive operations and should run through protected environments with explicit approvals.

## Identity and RBAC

The module creates no role assignments. Its execution identity must already have billing, subscription, management-group, provider-registration, and resource-group permissions appropriate to the selected mode. Apply least privilege separately to the vended subscription.

## Naming and Tagging

Set `name` explicitly or allow `sub-<workload>-<environment>-<instance>` generation. `subscription_name` is a deprecated compatibility alias. Tags are applied only to bootstrap resource groups; subscriptions and management-group associations do not accept ARM tags. See the repository [naming convention](../../docs/NAMING_CONVENTION.md) and [tagging standard](../../docs/TAGGING_STANDARD.md).

## Examples

- [`basic`](examples/basic/): management-group placement for an existing subscription
- [`complete`](examples/complete/): existing-subscription provider registrations and bootstrap resource groups
- [`new-subscription-alias`](examples/new-subscription-alias/): alias-only first stage for a new subscription

## Testing

`tests/unit.tftest.hcl` uses a mocked AzureRM provider. Its two plan-only tests require no Azure authentication, create no subscriptions or resources, and incur no cost.

```powershell
terraform -chdir=modules/subscription_vending init -backend=false
terraform -chdir=modules/subscription_vending test
```

## Known Limitations

- New-subscription vending and subscription bootstrap cannot safely be completed with one dynamically configured provider in a single apply; use two stages.
- The module does not create management groups, assign policy, create RBAC assignments, configure budgets, establish connectivity, or deploy a full landing zone.
- Alias deletion and subscription lifecycle behavior are governed by Azure billing APIs and are not equivalent to deleting ordinary ARM resources.
- Mocked tests cannot verify billing eligibility, tenant policy, management-group permissions, provider registration timing, or subscription quota.

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
| [azurerm_management_group_subscription_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group_subscription_association) | resource |
| [azurerm_resource_group.bootstrap](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_provider_registration.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_provider_registration) | resource |
| [azurerm_subscription.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subscription) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Deployment environment used for the generated Environment tag. | `string` | `"dev"` | no |
| <a name="input_billing_scope_id"></a> [billing\_scope\_id](#input\_billing\_scope\_id) | Billing scope ID used when creating a new subscription alias. | `string` | `""` | no |
| <a name="input_bootstrap_resource_groups"></a> [bootstrap\_resource\_groups](#input\_bootstrap\_resource\_groups) | Bootstrap resource groups to create in the subscription. | <pre>map(object({<br>    name     = string<br>    location = string<br>    tags     = optional(map(string), {})<br>  }))</pre> | `{}` | no |
| <a name="input_enable_management_group_association"></a> [enable\_management\_group\_association](#input\_enable\_management\_group\_association) | Whether to associate the subscription with management\_group\_id. Use this when management\_group\_id is produced by another resource and is unknown during plan. | `bool` | `true` | no |
| <a name="input_existing_subscription_id"></a> [existing\_subscription\_id](#input\_existing\_subscription\_id) | Existing subscription ID used when only associating or bootstrapping an existing subscription. | `string` | `""` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Instance identifier used when name is not provided. | `string` | `"001"` | no |
| <a name="input_management_group_id"></a> [management\_group\_id](#input\_management\_group\_id) | Optional management group ID used to associate the subscription. | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | Optional display name override for the subscription. Leave empty to generate one from the global naming convention. | `string` | `""` | no |
| <a name="input_resource_provider_registrations"></a> [resource\_provider\_registrations](#input\_resource\_provider\_registrations) | Resource providers to register in the subscription. | `list(string)` | `[]` | no |
| <a name="input_subscription_alias_enabled"></a> [subscription\_alias\_enabled](#input\_subscription\_alias\_enabled) | Whether to create a subscription alias and new subscription. | `bool` | `false` | no |
| <a name="input_subscription_alias_name"></a> [subscription\_alias\_name](#input\_subscription\_alias\_name) | Subscription alias name when subscription\_alias\_enabled is true. | `string` | `""` | no |
| <a name="input_subscription_name"></a> [subscription\_name](#input\_subscription\_name) | Deprecated alias for name. Use name for the subscription display name override. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Default tags applied to bootstrap resource groups. | `map(string)` | `{}` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Workload identifier used in tagging. | `string` | `"platform"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bootstrap_resource_group_ids"></a> [bootstrap\_resource\_group\_ids](#output\_bootstrap\_resource\_group\_ids) | Bootstrap resource group IDs keyed by logical name. |
| <a name="output_management_group_subscription_association_id"></a> [management\_group\_subscription\_association\_id](#output\_management\_group\_subscription\_association\_id) | Management group association resource ID when created. |
| <a name="output_merged_tags"></a> [merged\_tags](#output\_merged\_tags) | Final merged tags applied to bootstrap resource groups. |
| <a name="output_registered_resource_providers"></a> [registered\_resource\_providers](#output\_registered\_resource\_providers) | Registered resource providers. |
| <a name="output_subscription_alias_id"></a> [subscription\_alias\_id](#output\_subscription\_alias\_id) | Subscription alias resource ID when a new subscription alias is created. |
| <a name="output_subscription_id"></a> [subscription\_id](#output\_subscription\_id) | Subscription ID that was created or targeted. |
<!-- END_TF_DOCS -->
