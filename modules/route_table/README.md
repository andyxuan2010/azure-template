# Route Table Module

Create Azure route tables and associate them with one or more subnets.

The module inherits resource-group tags when requested, lets caller tags override inherited values, and does not generate implicit tags. Route validation enforces supported next-hop types and requires `next_hop_in_ip_address` only for `VirtualAppliance`.

## Example

```hcl
module "route_table" {
  source = "./modules/route_table"

  name                = "rt-platform-prod-001"
  resource_group_name = "rg-platform-prod"
  location            = "canadacentral"

  routes = {
    default = {
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.0.4"
    }
  }

  subnet_ids = [
    azurerm_subnet.application.id
  ]
}
```

## Testing

Tests are provider-mocked and plan-only.

```powershell
terraform init -backend=false
terraform test -filter='tests\live.tftest.hcl'
```
