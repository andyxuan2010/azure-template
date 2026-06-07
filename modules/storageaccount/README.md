# Storage Account Module

Provision Azure Storage Account with RBAC, secure authentication defaults, network rules, private endpoints, and diagnostics.

## Overview

- Providers: `azuread`, `azurerm`, `random`
- Inputs: 40
- Outputs: 21
- Nested modules: 0
- Terraform tests: `tests/live.tftest.hcl`

## Features

- Creates managed resources including `azurerm_monitor_diagnostic_setting`, `azurerm_private_endpoint`, `azurerm_role_assignment`, `azurerm_storage_account`, `azurerm_storage_account_network_rules`.
- Supports resource-level RBAC inputs for administrative and read-only access patterns.
- Grants each `app_admin_group` principal storage account `Contributor` plus Blob, File, Queue, and Table data-plane roles.
- Grants the current Terraform execution identity `Contributor`, `Storage Blob Data Owner`, `Storage File Data SMB Share Elevated Contributor`, `Storage Queue Data Contributor`, and `Storage Table Data Contributor` by default. Set `grant_current_terraform_service_principal_storage_roles = false` to opt out.
- Supports private endpoint configuration using direct IDs or lookup inputs for the subnet and private DNS zones.
- Supports optional diagnostic settings to Log Analytics.
- Enables storage account network rules with a `Deny` default action by default for secure-by-default deployments.
- Defaults requests to Microsoft Entra authorization where supported through `default_to_oauth_authentication = true`.
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
    Owner = "Platform"
  }
}
```

By default, the module creates the storage account with public network access disabled and storage network rules enabled with a `Deny` default action. To allow access, provide `network_rules_ip_rules`, `network_rules_virtual_network_subnet_ids`, or use private endpoints.

The module also grants the Terraform execution identity `Contributor`, `Storage Blob Data Owner`, `Storage File Data SMB Share Elevated Contributor`, `Storage Queue Data Contributor`, and `Storage Table Data Contributor` at the storage account scope by default, which helps the same service principal manage storage control-plane and data-plane resources created by Terraform. Disable this behavior with `grant_current_terraform_service_principal_storage_roles = false` when those permissions are managed elsewhere.

Each `app_admin_group` entry is resolved to a Microsoft Entra group principal and receives `Contributor`, `Storage Blob Data Owner`, `Storage File Data SMB Share Elevated Contributor`, `Storage Queue Data Contributor`, and `Storage Table Data Contributor` at the storage account scope.

## Hardened Pattern

```hcl
module "storageaccount" {
  source = "./modules/storageaccount"
  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
  }

  resource_group_name             = "rg-example-prod"
  name                            = "stexampleprod001"
  default_to_oauth_authentication = true
  public_network_access_enabled   = false
  system_managed_identity_enabled = true

  managed_identity_role_assignments = {
    kv_crypto = {
      scope                = "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.KeyVault/vaults/<kv-name>"
      role_definition_name = "Key Vault Crypto Service Encryption User"
    }
  }

  private_endpoint_subresource_names = ["blob", "dfs"]
  private_endpoint_subnet_id         = "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/<pep-subnet>"
  private_dns_zone_ids = {
    blob = "/subscriptions/<subscription-id>/resourceGroups/<dns-rg>/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
    dfs  = "/subscriptions/<subscription-id>/resourceGroups/<dns-rg>/providers/Microsoft.Network/privateDnsZones/privatelink.dfs.core.windows.net"
  }
}
```

## Key Inputs

- `resource_group_name`: The name of the resource group where the storage account will be deployed. `string` (required)
- `app_admin_group`: List of Microsoft Entra group display names or object IDs that should receive Contributor plus Blob, File, Queue, and Table data-plane access to the storage account. Prefer object IDs when display names are not unique. `list(string)` (default: `[]`)
- `app_user_group`: List of Microsoft Entra group display names or object IDs that should receive Reader access to the storage account. Prefer object IDs when display names are not unique. `list(string)` (default: null)
- `enable_diagnostics`: Enable diagnostic settings for the storage account. `bool` (default: false)
- `enable_network_rules`: Whether to manage storage account network rules. `bool` (default: true)
- `default_to_oauth_authentication`: Default to Microsoft Entra authorization where supported. `bool` (default: true)
- `grant_current_terraform_service_principal_storage_roles`: Assign Contributor plus full storage data-plane roles for Blob, File, Queue, and Table services to the current Terraform execution identity at the storage account scope. `bool` (default: true)
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

- `app_admin_group_role_assignment_ids`: Map of Contributor role assignment IDs keyed by app_admin_group input.
- `app_admin_group_data_plane_role_assignment_ids`: Map of storage data-plane role assignment IDs keyed by app_admin_group input and role.
- `app_user_group_role_assignment_ids`: Map of Reader role assignment IDs keyed by app_user_group display name.
- `diagnostic_setting_id`: The ID of the diagnostic setting, if created.
- `id`: The ID of the storage account.
- `identity`: The identity block of the storage account.
- `location`: The location of the storage account.
- `managed_identity_role_assignment_ids`: Map of managed identity role assignment IDs keyed by assignment name.
- `name`: The name of the storage account.
- `network_rules_id`: The ID of the storage account network rules resource, if created.
- `primary_blob_endpoint`: The primary blob endpoint.
- `private_endpoint_fqdns`: Map of private endpoint FQDNs keyed by subresource.
- `private_endpoint_ip_addresses`: Map of private endpoint IPs keyed by subresource.
- `terraform_execution_identity_role_assignment_ids`: Map of role assignment IDs created for the current Terraform execution identity.

## Testing

Run module tests from the module directory:

```powershell
terraform test
```

- `terraform test -filter='tests\live.tftest.hcl'`
