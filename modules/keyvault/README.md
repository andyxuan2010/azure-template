# Key Vault Module

Provision Azure Key Vault with RBAC, network ACLs, private endpoints, and diagnostics.

## Overview

- Providers: `azuread`, `azurerm`, `random`
- Inputs: 34
- Outputs: 12
- Nested modules: 0
- Terraform tests: `tests/live.tftest.hcl`

## Features

- Creates managed resources including `azurerm_key_vault`, `azurerm_monitor_diagnostic_setting`, `azurerm_private_endpoint`, `azurerm_role_assignment`, and `random_string`.
- Supports resource-level RBAC inputs for administrative and read-only access patterns.
- Supports explicit caller role grants; automatic elevation of the Terraform execution identity is disabled by default.
- Supports private endpoint configuration using direct IDs or lookup inputs for the subnet and private DNS zone.
- Supports optional diagnostic settings to Log Analytics.
- Enables network ACLs with a `Deny` default action by default for secure-by-default deployments.
- Uses the default AzureRM provider for private endpoint subnet and private DNS zone lookups.
- Enforces purge protection by default according to Azure best practices.
- Guards RBAC role assignment usage so it matches `enable_rbac_authorization`.
- Manages certificate contacts through the dedicated certificate contacts resource instead of the deprecated inline API.
- Includes Terraform test coverage files: `tests/live.tftest.hcl`.

## Basic Usage

```hcl
module "keyvault" {
  source = "./modules/keyvault"
  resource_group_name = "rg-example-prod"
  app_env             = "prod"

  tags = {
    Owner = "Platform"
  }
}
```

Caller role assignments are explicit opt-in. Enable them only when Terraform must manage both control-plane and data-plane access.

By default, the module creates the vault with public network access disabled and Key Vault network ACLs enabled with a `Deny` default action. To allow access, provide `network_acls_ip_rules`, `network_acls_virtual_network_subnet_ids`, or set up a private endpoint.

## Hardened Pattern

```hcl
module "keyvault" {
  source = "./modules/keyvault"
  resource_group_name = "rg-example-prod"
  name                = "kv-example-prod-001"
  app_env             = "prod"

  enable_rbac_authorization = true
  grant_current_terraform_service_principal_key_vault_roles = true
  public_network_access_enabled = false
  purge_protection_enabled      = true

  enable_private_endpoint    = true
  private_endpoint_subnet_id = "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/<pep-subnet>"
  private_dns_zone_id        = "/subscriptions/<subscription-id>/resourceGroups/<dns-rg>/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net"
}
```

## Key Inputs

- `resource_group_name`: The name of the resource group where the Key Vault will be deployed. `string` (required)
- `app_env`: Deployment environment used for standardisation and naming (dev, staging, prod, sbx, test, qa). `string` (default: "dev")
- `app_admin_group`: List of Entra group display names or object IDs that should receive Key Vault Administrator access. Prefer object IDs when display names are not unique. `list(string)` (default: null)
- `app_user_group`: List of Entra group display names or object IDs that should receive Key Vault Secrets User access. Prefer object IDs when display names are not unique. `list(string)` (default: null)
- `contacts`: A list of contacts for Key Vault certificates notifications. `list(object)` (default: [])
- `enable_diagnostics`: Enable diagnostic settings for the Key Vault. `bool` (default: false)
- `enable_network_acls`: Whether to configure Key Vault network ACLs. `bool` (default: true)
- `enable_private_endpoint`: Whether to create a private endpoint for the Key Vault. `bool` (default: false)
- `grant_current_terraform_service_principal_key_vault_roles`: Assign Contributor and Key Vault Administrator to the current Terraform execution identity at the Key Vault scope. `bool` (default: false)
- `grant_current_caller_secrets_officer`: Backward-compatible opt-in for granting only `Key Vault Secrets Officer`. `bool` (default: false)
- `log_analytics_workspace_id`: Log Analytics workspace resource ID for diagnostics. `string` (default: "")
- `network_acls_default_action`: Default action for Key Vault network ACLs. `string` (default: `"Deny"`)
- `network_acls_ip_rules`: IPv4 addresses or CIDR ranges allowed by the Key Vault network ACLs. `list(string)` (default: `[]`)
- `network_acls_virtual_network_subnet_ids`: Subnet resource IDs allowed by the Key Vault network ACLs. `list(string)` (default: `[]`)
- `private_dns_zone_id`: Optional Private DNS zone ID attached to the Key Vault private endpoint. `string` (default: "")
- `private_dns_zone_name`: Optional existing Private DNS zone name resolved through the default AzureRM provider when `private_dns_zone_id` is not set. `string` (default: `null`)
- `private_dns_zone_resource_group_name`: Resource group containing the private DNS zone used for lookup. `string` (default: `null`)
- `tags`: A mapping of tags to assign to the resources. `map(string)` (default: {})

## Private DNS Options

Use one of these patterns for private endpoint DNS:

- Direct ID via `private_dns_zone_id`
- Lookup by name via `private_dns_zone_name` plus `private_dns_zone_resource_group_name`

## Notable Outputs

- `app_admin_group_role_assignment_ids`: Map of Key Vault Administrator role assignment IDs keyed by app_admin_group input.
- `app_user_group_role_assignment_ids`: Map of Key Vault Secrets User role assignment IDs keyed by app_user_group input.
- `current_terraform_service_principal_role_assignment_ids`: Map of role assignment IDs created for the current Terraform execution identity.
- `diagnostic_setting_id`: The ID of the diagnostic setting, if created.
- `id`: The ID of the Key Vault.
- `location`: The location of the Key Vault.
- `name`: The name of the Key Vault.
- `private_endpoint_id`: The ID of the private endpoint, if created.
- `private_endpoint_fqdns`: The private endpoint FQDNs, if created.
- `private_endpoint_ip_addresses`: The private endpoint IPs, if created.
- `private_endpoint_name`: The name of the private endpoint, if created.
- `resource_group_name`: The resource group containing the Key Vault.
- `tags`: The effective tags assigned to the Key Vault.

## Testing

Run module tests from the module directory:

```powershell
terraform test
```

- `terraform test -filter='tests\live.tftest.hcl'`

Tests use mocked providers and do not deploy Azure resources.
