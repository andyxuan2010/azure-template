# Load Balancer Examples

## Internal Frontend

```hcl
module "loadbalancer" {
  source = "./modules/loadbalancer"

  name                = "lb-internal-prod"
  resource_group_name = "rg-platform-prod"
  location            = "canadacentral"

  frontend_ip_configurations = [{
    name                          = "internal"
    subnet_id                     = azurerm_subnet.application.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.20.1.10"
  }]

  backend_address_pools = [{ name = "application" }]
}
```

## Outbound Connectivity

```hcl
outbound_rules = [{
  name                           = "egress"
  protocol                       = "All"
  backend_address_pool_name      = "application"
  frontend_ip_configuration_name = "public"
}]
```
