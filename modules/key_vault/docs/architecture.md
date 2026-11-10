# Key Vault Architecture

The module separates the vault deployment subscription from the shared-network lookup subscription:

```text
Default azurerm provider
  └─ Key Vault, private endpoint, diagnostics, and RBAC

Aliased azurerm.prod provider
  └─ Optional lookup of existing private endpoint subnet and private DNS zone
```

Callers must pass both provider configurations. They may point to the same subscription in simple environments or different subscriptions in a hub-and-spoke platform.

## Private Connectivity Inputs

Direct IDs are preferred because they avoid lookup ambiguity:

- `private_endpoint_subnet_id`
- `private_dns_zone_id`

When direct IDs are unavailable, the module resolves names through `azurerm.prod`:

- subnet name, VNet name, and network resource group;
- private DNS zone name and DNS resource group.

The private endpoint connects to the `vault` subresource. The module attaches an existing `privatelink.vaultcore.azure.net` zone but does not create the zone or VNet links.

## Authorization Model

The module is designed for Azure RBAC authorization:

- admin principals receive Key Vault Administrator;
- user principals receive Key Vault Secrets User;
- current-caller bootstrap grants are disabled unless explicitly enabled.

Secrets, keys, certificates, rotation, expiration policy, and application-specific role assignments are deliberately separate concerns.

## Security Boundary

The default vault has public access disabled, network ACL default action `Deny`, RBAC authorization enabled, and purge protection enabled. A successful deployment does not imply immediate data-plane reachability: private DNS, network routing, RBAC propagation, and application identity permissions must also be operational.
