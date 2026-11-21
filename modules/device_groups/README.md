# Intune Targeting Groups

Creates Microsoft Entra security groups for targeting Intune policies and applications, including optional dynamic membership rules.

## Features
- Creates one or more security groups with stable caller-defined keys.
- Supports dynamic membership rules.

## Resources Created
Creates `azuread_group` resources.

## Prerequisites and Dependencies
Requires an Entra tenant and permission to create groups. Dynamic groups require the appropriate Entra licensing.

## Provider Configuration
Configure the `azuread` provider for the target tenant in the calling root module. Grant least-privilege directory permissions.

## Basic Usage
See [examples/basic](examples/basic/).

## Important Behavior and Secure Defaults
Groups are security-enabled and mail-disabled. Membership rules can target devices only when the chosen user/device attributes and tenant capabilities support the rule. Review rule scope before assigning production policies.

## Testing
No module test is included in this initial integration. Run `terraform init -backend=false` and `terraform validate` in the example after configuring the provider.

## Known Limitations
Dynamic group evaluation is asynchronous and depends on tenant licensing and directory processing.

## Terraform Reference
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0, < 2.0.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | >= 3.0, < 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | >= 3.0, < 4.0 |

## Resources

| Name | Type |
|------|------|
| [azuread_group.this](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_groups"></a> [groups](#input\_groups) | Map of Entra security groups and optional dynamic membership rules. | `map(object({ display_name = string, description = optional(string), membership_rule = optional(string) }))` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_group_ids"></a> [group\_ids](#output\_group\_ids) | Entra group object IDs keyed by caller-supplied group key. |
<!-- END_TF_DOCS -->
