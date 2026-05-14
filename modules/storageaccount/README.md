# Storage Account Module

Provision Azure Storage Account with RBAC, network rules, private endpoints, and diagnostics.

## Overview

- Providers: `azuread` `3.8.0`, `azurerm` `4.65.0`, `random` `3.8.1`
- Inputs: 40
- Outputs: 20
- Nested modules: 0
- Terraform tests: `tests/live.tftest.hcl`

## Features

- Creates managed resources including `azurerm_monitor_diagnostic_setting`, `azurerm_private_endpoint`, `azurerm_role_assignment`, `azurerm_storage_account`, `azurerm_storage_account_network_rules`.
- Supports resource-level RBAC inputs for administrative and read-only access patterns.
- Supports private endpoint configuration using direct IDs or lookup inputs for the subnet and private DNS zones.
- Supports optional diagnostic settings to Log Analytics.
- Enables storage account network rules with a `Deny` default action by default for secure-by-default deployments.
- Requires callers to pass `azurerm.prod` when private endpoint subnet lookup is used.
- Includes Terraform test coverage files: `tests/live.tftest.hcl`.

## Basic Usage

```hcl
module "storageaccount" {
  source = "./modules/storageaccount"
  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
  }

  resource_group_name = "rg-example-prod"

  tags = {
    ManagedBy = "Terraform"
  }
}
```

By default, the module creates the storage account with public network access disabled and storage network rules enabled with a `Deny` default action. To allow access, provide `network_rules_ip_rules`, `network_rules_virtual_network_subnet_ids`, or use private endpoints.

## Key Inputs

- `resource_group_name`: The name of the resource group where the storage account will be deployed. `string` (required)
- `app_admin_group`: List of Microsoft Entra group display names or object IDs that should receive Contributor access to the storage account. Prefer object IDs when display names are not unique. `list(string)` (default: null)
- `app_user_group`: List of Microsoft Entra group display names or object IDs that should receive Reader access to the storage account. Prefer object IDs when display names are not unique. `list(string)` (default: null)
- `enable_diagnostics`: Enable diagnostic settings for the storage account. `bool` (default: false)
- `enable_network_rules`: Whether to manage storage account network rules. `bool` (default: true)
- `log_analytics_workspace_id`: Log Analytics workspace resource ID for diagnostics. Required when enable_diagnostics is true. `string` (default: "")
- `network_rules_default_action`: Default action for storage account network rules. `string` (default: `"Deny"`)
- `network_rules_ip_rules`: IPv4 addresses or CIDR ranges allowed by network rules. `list(string)` (default: `[]`)
- `network_rules_virtual_network_subnet_ids`: Subnet resource IDs allowed by network rules. `list(string)` (default: `[]`)
- `private_dns_zone_ids`: Optional private DNS zone IDs keyed by private endpoint subresource name. `map(string)` (default: `{}`)
- `private_dns_zone_names`: Optional private DNS zone names keyed by private endpoint subresource name, resolved through `azurerm.prod` when matching IDs are not provided. `map(string)` (default: `{}`)
- `private_dns_zone_resource_group_name`: Resource group containing the private DNS zones used for private endpoint lookup. `string` (default: `null`)
- `tags`: A mapping of tags to assign to the resources. `map(string)` (default: {})

## Private DNS Options

Use one of these patterns for private endpoint DNS:

- Direct IDs via `private_dns_zone_ids`, for example `{ blob = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net" }`
- Lookup by name via `private_dns_zone_names` plus `private_dns_zone_resource_group_name`, for example `{ blob = "privatelink.blob.core.windows.net" }`

## Notable Outputs

- `app_admin_group_role_assignment_ids`: Map of Contributor role assignment IDs keyed by app_admin_group display name.
- `app_user_group_role_assignment_ids`: Map of Reader role assignment IDs keyed by app_user_group display name.
- `diagnostic_setting_id`: The ID of the diagnostic setting, if created.
- `id`: The ID of the storage account.
- `identity`: The identity block of the storage account.
- `location`: The location of the storage account.
- `managed_identity_role_assignment_ids`: Map of managed identity role assignment IDs keyed by assignment name.
- `name`: The name of the storage account.
- `network_rules_id`: The ID of the storage account network rules resource, if created.
- `primary_blob_endpoint`: The primary blob endpoint.

## Testing

Run module tests from the module directory:

```powershell
terraform test
```

- `terraform test -filter='tests\live.tftest.hcl'`
