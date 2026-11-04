mock_provider "azurerm" {}
mock_provider "azuread" {}

variables {
  resource_group_name  = "rg-network-prod"
  virtual_network_name = "vnet-hub-prod"
  virtual_network_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network-prod/providers/Microsoft.Network/virtualNetworks/vnet-hub-prod"

  subnets = {
    application = {
      address_prefixes                          = ["10.20.1.0/24"]
      service_endpoints                         = ["Microsoft.Storage"]
      network_security_group_id                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network-prod/providers/Microsoft.Network/networkSecurityGroups/nsg-application"
      create_network_security_group_association = true
      route_table_id                            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network-prod/providers/Microsoft.Network/routeTables/rt-application"
      create_route_table_association            = true
    }
    private_endpoints = {
      address_prefixes                  = ["10.20.2.0/24"]
      private_endpoint_network_policies = "Disabled"
    }
  }

  app_admin_group = ["11111111-1111-1111-1111-111111111111"]
  app_user_group  = ["22222222-2222-2222-2222-222222222222"]
}

run "plan_subnets_associations_and_rbac" {
  command = plan

  assert {
    condition     = length(azurerm_subnet.this) == 2
    error_message = "Expected two subnets."
  }

  assert {
    condition     = azurerm_subnet.this["application"].virtual_network_name == var.virtual_network_name && contains(azurerm_subnet.this["application"].service_endpoints, "Microsoft.Storage")
    error_message = "Subnet virtual network name or service endpoints were not planned correctly."
  }

  assert {
    condition     = azurerm_subnet.this["private_endpoints"].private_endpoint_network_policies == "Disabled"
    error_message = "Private endpoint network policy was not passed through."
  }

  assert {
    condition     = length(azurerm_subnet_network_security_group_association.this) == 1 && length(azurerm_subnet_route_table_association.this) == 1
    error_message = "Expected one NSG association and one route table association."
  }

  assert {
    condition     = length(azurerm_role_assignment.app_admin_group) == 1 && length(azurerm_role_assignment.app_user_group) == 1
    error_message = "Expected one admin and one user role assignment."
  }
}

run "plan_delegated_subnet" {
  command = plan

  variables {
    subnets = {
      app_service = {
        address_prefixes = ["10.20.3.0/24"]
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

  assert {
    condition     = length(azurerm_subnet.this["app_service"].delegation) == 1
    error_message = "Expected one subnet delegation."
  }
}

run "reject_non_aligned_prefix" {
  command = plan

  variables {
    subnets = {
      invalid = {
        address_prefixes = ["10.20.1.1/24"]
      }
    }
  }

  expect_failures = [
    var.subnets,
  ]
}
