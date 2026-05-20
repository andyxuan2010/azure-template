# Key Vault Examples

Examples below were regenerated from the current `keyvault` module interface.

## Example 1: Minimal

```hcl
module "keyvault" {
  source = "./modules/keyvault"
  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
  }

  resource_group_name = "rg-example-prod"
}
```

## Example 2: Common Pattern

```hcl
module "keyvault" {
  source = "./modules/keyvault"
  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
  }

  resource_group_name = "rg-example-prod"
  app_admin_group                    = ["00000000-0000-0000-0000-000000000000"]
  app_user_group                     = ["00000000-0000-0000-0000-000000000000"]
  grant_current_caller_secrets_officer = true
  enable_private_endpoint            = false
  enable_diagnostics                 = false
  log_analytics_workspace_id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/<provider>/<type>/<name>"
  tags = {
    ManagedBy = "Terraform"
  }
}
```

## Example 3: Private Endpoint DNS Lookup By Name

```hcl
module "keyvault" {
  source = "./modules/keyvault"
  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
  }

  resource_group_name = "rg-example-prod"
  enable_private_endpoint = true
  private_endpoint_subnet_name                 = "snet-example-private-endpoints"
  private_endpoint_vnet_name                   = "vnet-example-prod"
  private_endpoint_network_resource_group_name = "rg-example-network-prod"
  private_dns_zone_name                        = "privatelink.vaultcore.azure.net"
  private_dns_zone_resource_group_name         = "rg-example-network-prod"
}
```

## Example 4: RBAC-Managed Vault With Direct Private DNS Zone ID

```hcl
module "keyvault" {
  source = "./modules/keyvault"
  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
  }

  resource_group_name               = "rg-example-prod"
  app_env                           = "prod"
  enable_rbac_authorization         = true
  grant_current_caller_secrets_officer = true
  enable_private_endpoint           = true
  private_endpoint_subnet_id        = "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/<pep-subnet>"
  private_dns_zone_id               = "/subscriptions/<subscription-id>/resourceGroups/<dns-rg>/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net"
}
```

## Notes

- Replace placeholder IDs, names, and resource IDs with environment-specific values.
- Prefer Entra object IDs over display names when group names are duplicated.
- For private endpoint and diagnostics options, supply the full dependent inputs together.
- When using DNS lookup by name, pass `azurerm.prod` and set `private_dns_zone_resource_group_name`.

## Related Terraform Tests

- `tests/live.tftest.hcl`
