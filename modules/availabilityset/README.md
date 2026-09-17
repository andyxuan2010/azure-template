# Azure Availability Set

Provisions an Azure Availability Set with standardized naming, configurable fault and update domains, optional proximity placement group placement, and consistent tag inheritance.

## Features

- Supports explicit names or generated names based on workload, environment, location, and instance.
- Configures managed-disk support and platform fault and update domains.
- Associates the Availability Set with an existing proximity placement group when low-latency placement is required.
- Merges resource-group tags with module-specific tags.
- Supports custom create, read, update, and delete timeouts.

## Resources Created

The module always creates one `azurerm_availability_set`. It reads the target resource group only when location or inherited tags are not supplied directly. A proximity placement group is referenced by ID and is not managed by this module.

## Prerequisites and Dependencies

- An existing Azure resource group.
- An optional existing proximity placement group in a compatible region.
- Terraform `>= 1.6.0` and AzureRM provider `>= 4.0, < 5.0`.
- Permission to read the resource group and manage Availability Sets.

Pass dependency outputs from the calling composition. Supplying `location` and `inherited_resource_group_tags` keeps those values plan-known and avoids a resource-group lookup.

## Provider Configuration

Configure the AzureRM provider in the calling root module:

```hcl
provider "azurerm" {
  features {}
}
```

The reusable module declares provider requirements but does not configure providers.

## Basic Usage

See the executable [basic example](examples/basic/).

```hcl
module "availability_set" {
  source = "../../modules/availabilityset"

  resource_group_name = azurerm_resource_group.workload.name
  workload_name       = "payments"
  app_env              = "prod"
  location             = azurerm_resource_group.workload.location
  tags                 = local.tags
}
```

## Important Behavior and Secure Defaults

- `managed` defaults to `true`, which is appropriate for virtual machines using managed disks.
- Fault-domain support varies by Azure region. Confirm that `platform_fault_domain_count` is supported in the target region.
- Changing placement-related settings can force replacement and may require coordinated virtual-machine changes.
- The module does not attach virtual machines to the Availability Set; callers pass the resulting ID to their VM composition.
- Explicitly supplying inherited tags is recommended in compositions where plan-time tag visibility matters.

## Naming and Tagging

Set `name` for an explicit Azure resource name. Otherwise, the module generates a name from `name_prefix`, location, workload, environment, and instance inputs. When `inherit_resource_group_tags` is enabled, explicit `tags` override inherited values with the same key.

## Testing

Run the mocked unit tests from the module directory:

```shell
terraform init -backend=false
terraform test
```

Validate the executable configurations under `examples/` with `terraform init -backend=false` followed by `terraform validate`.

## Known Limitations

- Availability Sets provide datacenter fault-domain isolation; they are not a substitute for Availability Zones.
- The module manages one Availability Set and does not manage its virtual-machine members.
- Region-specific fault-domain limits and proximity placement constraints remain the caller's responsibility.

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
| [azurerm_availability_set.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/availability_set) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Deployment environment used for generated naming. | `string` | `"dev"` | no |
| <a name="input_inherit_resource_group_tags"></a> [inherit\_resource\_group\_tags](#input\_inherit\_resource\_group\_tags) | Whether to merge tags from the target resource group into the Availability Set. | `bool` | `true` | no |
| <a name="input_inherited_resource_group_tags"></a> [inherited\_resource\_group\_tags](#input\_inherited\_resource\_group\_tags) | Optional plan-known resource group tags supplied by the root composition. When null and inherit\_resource\_group\_tags is true, the module reads the resource group. | `map(string)` | `null` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Instance identifier used when name is not provided. | `string` | `"001"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region. Leave empty to read the target resource group's location. | `string` | `""` | no |
| <a name="input_location_code"></a> [location\_code](#input\_location\_code) | Optional short location code used when the Availability Set name is generated. | `string` | `""` | no |
| <a name="input_managed"></a> [managed](#input\_managed) | Whether the Availability Set is managed. Use true for VMs with managed disks. | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Optional Availability Set name override. Leave empty to generate one from the naming convention. | `string` | `""` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix used when the Availability Set name is generated. | `string` | `"avail"` | no |
| <a name="input_platform_fault_domain_count"></a> [platform\_fault\_domain\_count](#input\_platform\_fault\_domain\_count) | Number of fault domains for the Availability Set. | `number` | `2` | no |
| <a name="input_platform_update_domain_count"></a> [platform\_update\_domain\_count](#input\_platform\_update\_domain\_count) | Number of update domains for the Availability Set. | `number` | `5` | no |
| <a name="input_proximity_placement_group_id"></a> [proximity\_placement\_group\_id](#input\_proximity\_placement\_group\_id) | Optional proximity placement group resource ID. | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group where the Availability Set is deployed. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for the Availability Set. | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Optional timeouts for Availability Set create, read, update, and delete operations. | <pre>object({<br>    create = optional(string)<br>    read   = optional(string)<br>    update = optional(string)<br>    delete = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Deprecated compatibility input. Supply workload\_name or workload tags explicitly where possible. | `string` | `"project"` | no |
| <a name="input_workload_name"></a> [workload\_name](#input\_workload\_name) | Optional workload segment used when the Availability Set name is generated. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the Availability Set. |
| <a name="output_location"></a> [location](#output\_location) | The Azure region of the Availability Set. |
| <a name="output_location_code"></a> [location\_code](#output\_location\_code) | The short location code used for generated naming. |
| <a name="output_managed"></a> [managed](#output\_managed) | Whether the Availability Set is managed. |
| <a name="output_name"></a> [name](#output\_name) | The name of the Availability Set. |
| <a name="output_platform_fault_domain_count"></a> [platform\_fault\_domain\_count](#output\_platform\_fault\_domain\_count) | The configured fault domain count. |
| <a name="output_platform_update_domain_count"></a> [platform\_update\_domain\_count](#output\_platform\_update\_domain\_count) | The configured update domain count. |
| <a name="output_proximity_placement_group_id"></a> [proximity\_placement\_group\_id](#output\_proximity\_placement\_group\_id) | The proximity placement group ID assigned to the Availability Set, if any. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The resource group containing the Availability Set. |
| <a name="output_tags"></a> [tags](#output\_tags) | Effective tags applied to the Availability Set. |
<!-- END_TF_DOCS -->
