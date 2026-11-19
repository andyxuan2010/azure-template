# Intune Baseline

Provides a reusable Terraform module for intune baseline using Microsoft Graph and the provider already used in this repository.

## Features

- Manages multiple named objects or actions in one module call.
- Uses Microsoft Graph API version `beta` by default.
- Returns Graph IDs and response data where the endpoint provides them.

## Resources Created

Creates one `msgraph_resource` for each entry at `deviceManagement/deviceConfigurations`. The Graph object body is supplied by the caller.

## Prerequisites and Dependencies

- An Intune-licensed Microsoft 365 tenant and an execution identity with the Graph permissions required for the selected object and operation.
- Admin consent for required application permissions.
- Confirm the specific endpoint supports the create/read/update/delete lifecycle before managing production settings.

## Provider Configuration

Configure the `msgraph` provider in the calling root module for the intended tenant. This module declares its provider requirement but contains no provider configuration. Use the least-privilege permissions documented for the Microsoft Graph API operation.

## Basic Usage

See [examples/basic](examples/basic/) for an executable configuration. Replace the example body with a complete, reviewed object of the correct Graph subtype.

## Important Behavior and Secure Defaults

The module passes the supplied body to Graph and does not invent policy values. Changes can affect enrolled devices. Start in a nonproduction tenant, review plans, and use `v1.0` when the resource is supported there; beta APIs may change.

## Testing

No module tests are included in this initial integration. The examples require Graph authentication to plan against a live tenant. Initialize and validate an example with `terraform init -backend=false` and `terraform validate`.

## Known Limitations

- Dynamic request bodies are not validated against subtype-specific Graph schemas.
- Graph licensing, permissions, throttling, tenant policy, and endpoint lifecycle behavior can affect apply and destroy operations.
- Autopilot import records and app uploads may have workflows or payload requirements beyond basic object creation; verify the Microsoft Graph documentation before production use.

## Terraform Reference

The content below is generated from the module source. Do not edit it manually.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0, < 2.0.0 |
| <a name="requirement_msgraph"></a> [msgraph](#requirement\_msgraph) | >= 0.3, < 1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_msgraph"></a> [msgraph](#provider\_msgraph) | >= 0.3, < 1.0 |

## Resources

| Name | Type |
|------|------|
| [msgraph_resource.this](https://registry.terraform.io/providers/microsoft/msgraph/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_version"></a> [api\_version](#input\_api\_version) | Microsoft Graph API version used for this resource collection. | `string` | `"beta"` | no |
| <a name="input_resources"></a> [resources](#input\_resources) | Map of named Microsoft Graph request bodies to create at the deviceManagement/deviceConfigurations collection. | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resource_ids"></a> [resource\_ids](#output\_resource\_ids) | Microsoft Graph IDs keyed by the caller-supplied resource key. |
| <a name="output_resources"></a> [resources](#output\_resources) | Selected Graph response fields keyed by the caller-supplied resource key. |
<!-- END_TF_DOCS -->
