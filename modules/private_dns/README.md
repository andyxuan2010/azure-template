# Private DNS Module

Creates Azure Private DNS zones, VNet links, SOA configuration, and A, AAAA, CNAME, and TXT records.

Tags are fully managed on zones, links, and records. Explicit `tags` override optional `inherited_resource_group_tags`.

## Example

```hcl
module "private_dns" {
  source = "./modules/private_dns"

  resource_group_name = "rg-dns-prod"

  zones = {
    "privatelink.vaultcore.azure.net" = {
      vnet_links = {
        hub = {
          virtual_network_id = azurerm_virtual_network.hub.id
        }
      }

      a_records = {
        vault = {
          ttl     = 300
          records = ["10.20.1.10"]
        }
      }

      cname_records = {
        alias = {
          ttl    = 300
          record = "vault.privatelink.vaultcore.azure.net"
        }
      }
    }
  }
}
```

Tests use a mocked AzureRM provider.
