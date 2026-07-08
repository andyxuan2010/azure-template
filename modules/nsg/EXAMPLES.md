# NSG Examples

## Workload NSG

```hcl
module "workload_nsg" {
  source = "./modules/nsg"

  name                = "nsg-workload-dev-001"
  resource_group_name = "rg-workload-dev"
  location            = "canadacentral"

  security_rules = {
    allow_rdp_from_jump = {
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3389"
      source_address_prefix      = "10.0.10.0/24"
      destination_address_prefix = "*"
    }
  }
}
```

## Subnet Association

```hcl
subnet_ids = [
  module.vnet.subnet_ids["snet-workload"]
]
```

Association IDs must be unique, fully qualified Azure resource IDs.
