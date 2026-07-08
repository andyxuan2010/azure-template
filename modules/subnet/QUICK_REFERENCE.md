# Subnet Quick Reference

```hcl
module "subnet" {
  source = "./modules/subnet"

  resource_group_name  = "rg-network-dev"
  virtual_network_name = "vnet-platform-dev"
  virtual_network_id   = module.vnet.id

  subnets = {
    app = {
      address_prefixes          = ["10.10.1.0/24"]
      service_endpoints         = ["Microsoft.Storage"]
      network_security_group_id = module.nsg.id
      route_table_id            = module.route_table.id
    }
  }
}
```

Common outputs:

- `module.subnet.ids["app"]`
- `module.subnet.names["app"]`
- `module.subnet.network_security_group_association_ids["app"]`
- `module.subnet.route_table_association_ids["app"]`
