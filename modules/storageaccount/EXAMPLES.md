# Storage Account Examples

Examples below were regenerated from the current `storageaccount` module interface.

## Example 1: Minimal

```hcl
module "storageaccount" {
  source = "./modules/storageaccount"
  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
  }

  resource_group_name = "rg-example-prod"
}
```

## Example 2: Common Pattern

```hcl
module "storageaccount" {
  source = "./modules/storageaccount"
  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
  }

  resource_group_name = "rg-example-prod"
  default_to_oauth_authentication = true
  app_admin_group                 = ["00000000-0000-0000-0000-000000000000"]
  app_user_group                  = ["00000000-0000-0000-0000-000000000000"]
  enable_diagnostics              = false
  log_analytics_workspace_id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/<provider>/<type>/<name>"
  tags = {
    ManagedBy = "Terraform"
  }
}
```

## Example 3: Private Endpoint DNS Lookup By Name

```hcl
module "storageaccount" {
  source = "./modules/storageaccount"
  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
  }

  resource_group_name = "rg-example-prod"

  private_endpoint_subnet_name                 = "snet-example-private-endpoints"
  private_endpoint_vnet_name                   = "vnet-example-prod"
  private_endpoint_network_resource_group_name = "rg-example-network-prod"
  private_endpoint_subresource_names           = ["blob"]

  private_dns_zone_names = {
    blob = "privatelink.blob.core.windows.net"
  }
  private_dns_zone_resource_group_name = "rg-example-network-prod"
}
```

## Example 4: Managed Identity With Secure Auth Defaults

```hcl
module "storageaccount" {
  source = "./modules/storageaccount"
  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
  }

  resource_group_name             = "rg-example-prod"
  default_to_oauth_authentication = true
  system_managed_identity_enabled = true

  managed_identity_role_assignments = {
    cmk = {
      scope                = "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.KeyVault/vaults/<kv-name>"
      role_definition_name = "Key Vault Crypto Service Encryption User"
    }
  }
}
```

## Notes

- Replace placeholder IDs, names, and resource IDs with environment-specific values.
- Prefer Entra object IDs over display names when group names are duplicated.
- `app_admin_group` receives storage account `Contributor` plus Blob, File, Queue, and Table data-plane roles.
- For private endpoint and diagnostics options, supply the full dependent inputs together.
- When using DNS lookup by name, pass `azurerm.prod` and set `private_dns_zone_resource_group_name`.

## Related Terraform Tests

- `tests/live.tftest.hcl`
