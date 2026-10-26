# Azure Event Grid System Topic

Provisions one Azure Event Grid System Topic for an existing Azure resource with normalized naming, resource-group tag inheritance, optional managed identity, and explicit topic-source inputs.

## Features

- Creates one `azurerm_eventgrid_system_topic` for an existing Azure event source.
- Supports generated or explicit system topic names.
- Reads location and inherited tags from an existing resource group when requested.
- Supports Azure topic types such as `Microsoft.Storage.StorageAccounts` and other provider-supported resource types.
- Supports system-assigned and user-assigned managed identity.
- Supports configurable create, read, update, and delete timeouts.
- Exposes Azure's source and metric resource identifiers as outputs.

## Resources Created

The module always creates one `azurerm_eventgrid_system_topic`. The source resource and resource group are existing dependencies and are not managed. Event subscriptions and delivery endpoints are not created.

See [architecture](docs/architecture.md) for the resource boundary and ownership model.

## Prerequisites and Dependencies

- Terraform 1.6 or newer.
- AzureRM provider 4.x.
- An existing resource group.
- An existing Azure resource that supports Event Grid system topics.
- A `topic_type` compatible with `source_resource_id`.
- Azure permissions to create and manage Event Grid system topics in the resource group.

## Provider Configuration

Configure AzureRM in the calling root module:

```hcl
provider "azurerm" {
  features {}
}
```

## Basic Usage

```hcl
module "eventgridsystemtopic" {
  source = "./modules/eventgridsystemtopic"

  name                = "egt-orders-prod-001"
  resource_group_name = "rg-orders-prod"
  location            = "canadacentral"
  topic_type          = "Microsoft.Storage.StorageAccounts"
  source_resource_id  = "/subscriptions/<subscription-id>/resourceGroups/rg-orders-prod/providers/Microsoft.Storage/storageAccounts/stordersprod001"
}
```

The executable configurations are in [`examples/basic`](examples/basic/) and [`examples/complete`](examples/complete/).

## Topic Type and Source Resource

The source resource must already exist, and `topic_type` must identify its Azure provider resource type. The module validates that the source is a full Azure resource ID, but Azure remains authoritative for compatibility and regional support. Use the source resource's Terraform output rather than copying IDs into `terraform.tfvars` where possible.

## Identity and Event Delivery

Managed identity is disabled by default and this module does not assign permissions. Create event subscriptions separately and grant the selected identity or delivery destination only the permissions needed by the event workflow. Webhook secrets, dead-letter storage, retry behavior, and endpoint filters remain caller-owned.

## Naming and Tagging

Provide `name` for a stable explicit name or leave it empty to generate a name from the `egt` prefix, workload, location code, environment, and instance. Caller tags override inherited resource-group tags.

Follow the repository [naming convention](../../docs/60-security-governance/naming-convention.md) and [tagging standard](../../docs/60-security-governance/tagging-standard.md).

## Testing

`tests/unit.tftest.hcl` uses a mocked AzureRM provider and plan-only tests. It creates no Azure resources and requires no Azure authentication.

```powershell
terraform init -backend=false
terraform validate
terraform test
```

## Known Limitations

- The module does not create resource groups, source resources, Event Grid event subscriptions, delivery endpoints, dead-letter storage, custom topics, domains, private endpoints, or RBAC assignments.
- Mocked tests cannot prove Azure topic-type compatibility, source existence, regional support, event delivery, DNS, or policy effects.
- Event Grid service limits, billing, and delivery behavior depend on the source resource and caller-owned subscriptions.

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
| [azurerm_eventgrid_system_topic.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventgrid_system_topic) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Deployment environment used when the Event Grid System Topic name is generated. | `string` | `"dev"` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | User-assigned managed identity resource IDs used when identity\_type includes UserAssigned. | `list(string)` | `[]` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | Optional managed identity type for the Event Grid System Topic. | `string` | `null` | no |
| <a name="input_inherit_resource_group_tags"></a> [inherit\_resource\_group\_tags](#input\_inherit\_resource\_group\_tags) | Whether to merge tags from the target resource group into the Event Grid System Topic. | `bool` | `true` | no |
| <a name="input_inherited_resource_group_tags"></a> [inherited\_resource\_group\_tags](#input\_inherited\_resource\_group\_tags) | Optional plan-known resource group tags. When null and inheritance is enabled, the module reads the resource group. | `map(string)` | `null` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Instance identifier used when the Event Grid System Topic name is generated. | `string` | `"001"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the Event Grid System Topic. Leave empty to use the existing resource group's location. | `string` | `""` | no |
| <a name="input_location_code"></a> [location\_code](#input\_location\_code) | Optional short location code used when the Event Grid System Topic name is generated. | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | Optional Event Grid System Topic name override. Leave empty to generate one from the naming convention. | `string` | `""` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix used when the Event Grid System Topic name is generated. | `string` | `"egt"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the existing resource group where the Event Grid System Topic is deployed. | `string` | n/a | yes |
| <a name="input_source_resource_id"></a> [source\_resource\_id](#input\_source\_resource\_id) | Full Azure resource ID for the resource that emits events to this system topic. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the Event Grid System Topic. Caller tags override inherited resource-group tags. | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Optional timeouts for Event Grid System Topic create, read, update, and delete operations. | <pre>object({<br>    create = optional(string)<br>    read   = optional(string)<br>    update = optional(string)<br>    delete = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_topic_type"></a> [topic\_type](#input\_topic\_type) | Event Grid topic type associated with the source resource, such as Microsoft.Storage.StorageAccounts. | `string` | n/a | yes |
| <a name="input_workload"></a> [workload](#input\_workload) | Compatibility workload segment used when workload\_name is empty. | `string` | `"project"` | no |
| <a name="input_workload_name"></a> [workload\_name](#input\_workload\_name) | Optional workload segment used when the Event Grid System Topic name is generated. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The resource ID of the Event Grid System Topic. |
| <a name="output_identity_principal_id"></a> [identity\_principal\_id](#output\_identity\_principal\_id) | The principal ID of the managed identity, if one is configured. |
| <a name="output_identity_tenant_id"></a> [identity\_tenant\_id](#output\_identity\_tenant\_id) | The tenant ID of the managed identity, if one is configured. |
| <a name="output_location"></a> [location](#output\_location) | The Azure region of the Event Grid System Topic. |
| <a name="output_metric_arm_resource_id"></a> [metric\_arm\_resource\_id](#output\_metric\_arm\_resource\_id) | The metric Azure Resource Manager resource ID returned by Azure, if available. |
| <a name="output_metric_resource_id"></a> [metric\_resource\_id](#output\_metric\_resource\_id) | The metric resource ID returned by Azure, if available. |
| <a name="output_name"></a> [name](#output\_name) | The Event Grid System Topic name. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The resource group containing the Event Grid System Topic. |
| <a name="output_source_resource_id"></a> [source\_resource\_id](#output\_source\_resource\_id) | The source Azure resource ID associated with the system topic. |
| <a name="output_tags"></a> [tags](#output\_tags) | The effective tags applied to the Event Grid System Topic. |
| <a name="output_topic_type"></a> [topic\_type](#output\_topic\_type) | The Event Grid topic type associated with the source resource. |
<!-- END_TF_DOCS -->
