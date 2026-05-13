# Azure Container Registry Examples

Examples below were regenerated from the current `acr` module interface.

## Example 1: Minimal

```hcl
module "acr" {
  source = "./modules/acr"
  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
  }

  resource_group_name = "rg-example-prod"
  location            = "eastus"
}
```

## Example 2: Common Pattern

```hcl
module "acr" {
  source = "./modules/acr"
  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
  }

  resource_group_name = "rg-example-prod"
  location            = "eastus"
  app_admin_group            = ["00000000-0000-0000-0000-000000000000"]
  app_user_group             = ["00000000-0000-0000-0000-000000000000"]
  enable_private_endpoint    = false
  enable_diagnostics         = false
  log_analytics_workspace_id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/<provider>/<type>/<name>"
  tags = {
    ManagedBy = "Terraform"
  }
}
```

## Example 3: Private Endpoint DNS Lookup By Name

```hcl
module "acr" {
  source = "./modules/acr"
  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
  }

  resource_group_name = "rg-example-prod"
  location            = "eastus"
  sku                     = "Premium"
  enable_private_endpoint = true
  private_endpoint_subnet_name                 = "snet-example-private-endpoints"
  private_endpoint_vnet_name                   = "vnet-example-prod"
  private_endpoint_network_resource_group_name = "rg-example-network-prod"
  private_dns_zone_name                        = "privatelink.azurecr.io"
  private_dns_zone_resource_group_name         = "rg-example-network-prod"
}
```

## Notes

- Replace placeholder IDs, names, and resource IDs with environment-specific values.
- Prefer Entra object IDs over display names when group names are duplicated.
- For private endpoint and diagnostics options, supply the full dependent inputs together.
- When using DNS lookup by name, pass `azurerm.prod` and set `private_dns_zone_resource_group_name`.

## Related Terraform Tests

- `tests/live.tftest.hcl`
