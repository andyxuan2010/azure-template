mock_provider "azurerm" {}

variables {
  name                          = "rt-platform-dev"
  resource_group_name           = "rg-platform-dev"
  location                      = "canadacentral"
  inherited_resource_group_tags = {}

  routes = {
    default = {
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.0.4"
    }
  }

  tags = {
    Owner = "CCOE"
  }
}

run "plan_routes_and_tags" {
  command = plan

  assert {
    condition     = output.name == var.name && output.merged_tags.Owner == "CCOE"
    error_message = "Route table name or caller tags were not propagated."
  }

  assert {
    condition     = !contains(keys(output.merged_tags), "Environment")
    error_message = "Route table must not generate implicit tags."
  }
}

run "plan_subnet_association" {
  command = plan

  variables {
    subnet_ids = [
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-platform/subnets/snet-app"
    ]
  }

  assert {
    condition     = length(output.subnet_association_ids) == 1
    error_message = "Expected one subnet association."
  }
}

run "reject_virtual_appliance_without_ip" {
  command = plan

  variables {
    routes = {
      invalid = {
        address_prefix = "0.0.0.0/0"
        next_hop_type  = "VirtualAppliance"
      }
    }
  }

  expect_failures = [
    var.routes,
  ]
}

run "reject_ip_for_internet_hop" {
  command = plan

  variables {
    routes = {
      invalid = {
        address_prefix         = "0.0.0.0/0"
        next_hop_type          = "Internet"
        next_hop_in_ip_address = "10.0.0.4"
      }
    }
  }

  expect_failures = [
    var.routes,
  ]
}
