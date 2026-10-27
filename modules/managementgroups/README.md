# Azure Management Group

Provisions one Azure Management Group with an optional parent relationship and declarative subscription placement.

## Features

- Creates a management group with an explicit or generated immutable ID.
- Supports an independent display name.
- Attaches the group beneath an existing parent management group.
- Declaratively associates subscriptions with the group.
- Normalizes and rejects duplicate subscription IDs.
- Exposes caller-supplied metadata for downstream composition.

## Resources Created

- One Azure Management Group.
- An optional random suffix used only when `name` is omitted.

The parent management group, subscriptions, policies, role assignments, and subscription-vending workflow are outside this module.

## Prerequisites and Dependencies

- Terraform 1.6 or newer.
- Tenant-level permission to create management groups.
- Permission to move every supplied subscription into the target group.
- Existing parent management group when `parent_management_group_id` is set.
- A reviewed landing-zone hierarchy and governance ownership model.

Management groups should normally precede policy assignment and subscription vending.

## Provider Configuration

Configure AzureRM in the calling root module with credentials for the target tenant:

```hcl
provider "azurerm" {
  features {}
}
```

No resource group or Azure region is involved because management groups are tenant-scoped resources.

## Basic Usage

```hcl
module "platform_management_group" {
  source = "./modules/managementgroups"

  name                       = "platform"
  display_name               = "Platform"
  parent_management_group_id = "/providers/Microsoft.Management/managementGroups/contoso-root"
}
```

Runnable configurations are available in:

- [`examples/basic`](examples/basic/)
- [`examples/complete`](examples/complete/)

## Important Behavior

- `name` is the stable management group ID. Prefer setting it explicitly for long-lived governance anchors.
- Changing the management group ID replaces the resource.
- `subscription_ids` is declarative. Adding or removing an ID changes subscription placement and can change inherited policy and RBAC.
- Removing a subscription from this list does not define its next parent; coordinate placement through the owning composition.
- Management group creation and subscription association can be eventually consistent.
- Deletion can fail while child groups, subscriptions, assignments, or policies remain.

## Metadata

Azure Management Groups do not support ARM tags. The `tags` input and `tags`/`merged_tags` outputs are metadata only; they are not written to Azure. Use them for documentation or downstream composition, not policy enforcement.

## Naming

The management group ID and display name have different purposes. Keep the ID concise and stable while allowing a human-readable display name. Generated IDs contain a random suffix and are less suitable for permanent hierarchy anchors.

## Architecture

See [`docs/architecture.md`](docs/architecture.md) for hierarchy, inheritance, and subscription-placement boundaries.

## Testing

`tests/unit.tftest.hcl` uses mocked AzureRM and Random providers with plan-only and expected-failure runs:

```powershell
terraform init -backend=false
terraform validate
terraform test
```

No tenant resources or subscription moves occur in these tests.

## Known Limitations

- The module creates one management group per invocation rather than an entire hierarchy.
- Policy definitions, assignments, initiatives, RBAC, and subscription creation are not managed.
- The module cannot validate live tenant permissions or the current subscription hierarchy during mocked tests.
- Metadata tags are not Azure resource tags.

## Terraform Reference

The content below is generated from the module source. Do not edit it manually.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0, < 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0, < 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0, < 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.0, < 4.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_management_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Deployment environment metadata exposed for downstream consumers. | `string` | `"dev"` | no |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | Optional display name override for the management group. Leave empty to generate one from the global naming convention. | `string` | `""` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Instance identifier used when display\_name is not provided. | `string` | `"001"` | no |
| <a name="input_name"></a> [name](#input\_name) | Management group ID. If empty, a unique ID is generated from display\_name. | `string` | `""` | no |
| <a name="input_parent_management_group_id"></a> [parent\_management\_group\_id](#input\_parent\_management\_group\_id) | Optional parent management group resource ID. | `string` | `null` | no |
| <a name="input_subscription_ids"></a> [subscription\_ids](#input\_subscription\_ids) | Optional list of subscription IDs to associate with the management group. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Optional tags exposed as metadata for documentation and downstream consumers. | `map(string)` | `{}` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Workload identifier used in tagging. | `string` | `"platform"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_display_name"></a> [display\_name](#output\_display\_name) | The management group display name. |
| <a name="output_id"></a> [id](#output\_id) | The resource ID of the management group. |
| <a name="output_merged_tags"></a> [merged\_tags](#output\_merged\_tags) | Final merged tags emitted by this module for consistency with other modules. |
| <a name="output_name"></a> [name](#output\_name) | The management group ID. |
| <a name="output_parent_management_group_id"></a> [parent\_management\_group\_id](#output\_parent\_management\_group\_id) | The parent management group resource ID, if configured. |
| <a name="output_subscription_ids"></a> [subscription\_ids](#output\_subscription\_ids) | Subscription IDs associated to the management group. |
| <a name="output_tags"></a> [tags](#output\_tags) | Documentation tags emitted by this module. |
<!-- END_TF_DOCS -->
