# Subnet Module

Create and manage Azure subnets in an existing virtual network.

This module mirrors the subnet shape used by the `vnet` module and is intended for compositions where the virtual network already exists or subnets need to be managed separately from the virtual network lifecycle. It supports service endpoints, service endpoint policies, private endpoint network policy settings, subnet delegations, optional NSG and route table associations, and optional virtual-network scoped RBAC.

## Example

```hcl
module "subnet" {
  source = "./modules/subnet"

  resource_group_name  = "rg-network-prod"
  virtual_network_name = "vnet-hub-prod"
  virtual_network_id   = module.vnet.id

  subnets = {
    application = {
      address_prefixes          = ["10.20.1.0/24"]
      service_endpoints         = ["Microsoft.Storage"]
      network_security_group_id = module.nsg.id
      route_table_id            = module.route_table.id
    }
    private_endpoints = {
      address_prefixes                  = ["10.20.2.0/24"]
      private_endpoint_network_policies = "Disabled"
    }
  }

  app_admin_group = ["11111111-1111-1111-1111-111111111111"]
  app_user_group  = ["22222222-2222-2222-2222-222222222222"]
}
```

## Inputs

| Name | Description | Required |
|---|---|---|
| `resource_group_name` | Resource group containing the virtual network. | Yes |
| `virtual_network_name` | Existing virtual network name. | Yes |
| `virtual_network_id` | Optional virtual network ID used for RBAC scope. If empty, the module looks up the virtual network. | No |
| `subnets` | Map of subnet definitions keyed by subnet name. | Yes |
| `app_admin_group` | Entra group display names or object IDs granted Contributor on the virtual network scope. | No |
| `app_user_group` | Entra group display names or object IDs granted Reader on the virtual network scope. | No |

## Outputs

| Name | Description |
|---|---|
| `ids` | Subnet IDs keyed by subnet name. |
| `names` | Subnet names keyed by subnet name. |
| `address_prefixes` | Address prefixes keyed by subnet name. |
| `network_security_group_association_ids` | NSG association IDs keyed by subnet name. |
| `route_table_association_ids` | Route table association IDs keyed by subnet name. |
| `app_admin_group_role_assignment_ids` | Contributor assignment IDs keyed by app admin input. |
| `app_user_group_role_assignment_ids` | Reader assignment IDs keyed by app user input. |

## Testing

Tests are provider-mocked and plan-only.

```powershell
terraform init -backend=false
terraform test
```
