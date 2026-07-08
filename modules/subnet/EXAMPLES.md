# Subnet Module Examples

## Basic Subnets

```hcl
module "subnet" {
  source = "./modules/subnet"

  resource_group_name  = "rg-network-dev"
  virtual_network_name = "vnet-platform-dev"
  virtual_network_id   = module.vnet.id

  subnets = {
    app = {
      address_prefixes = ["10.10.1.0/24"]
    }
    data = {
      address_prefixes  = ["10.10.2.0/24"]
      service_endpoints = ["Microsoft.Storage", "Microsoft.Sql"]
    }
  }
}
```

## Private Endpoint Subnet

```hcl
module "private_endpoint_subnet" {
  source = "./modules/subnet"

  resource_group_name  = "rg-network-prod"
  virtual_network_name = "vnet-hub-prod"
  virtual_network_id   = module.vnet.id

  subnets = {
    private_endpoints = {
      address_prefixes                  = ["10.20.10.0/24"]
      private_endpoint_network_policies = "Disabled"
    }
  }
}
```

## Delegated App Service Subnet

```hcl
module "app_service_subnet" {
  source = "./modules/subnet"

  resource_group_name  = "rg-app-prod"
  virtual_network_name = "vnet-app-prod"
  virtual_network_id   = module.vnet.id

  subnets = {
    app_service = {
      address_prefixes = ["10.30.1.0/24"]

      delegations = {
        app_service = {
          name                    = "delegation-app-service"
          service_delegation_name = "Microsoft.Web/serverFarms"
          actions                 = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
      }
    }
  }
}
```

## Associations

```hcl
module "subnet" {
  source = "./modules/subnet"

  resource_group_name  = "rg-network-prod"
  virtual_network_name = "vnet-spoke-prod"
  virtual_network_id   = module.vnet.id

  subnets = {
    workload = {
      address_prefixes          = ["10.40.1.0/24"]
      network_security_group_id = module.nsg.id
      route_table_id            = module.route_table.id
    }
  }
}
```
