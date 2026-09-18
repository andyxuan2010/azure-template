mock_provider "azurerm" {}

variables {
  name                          = "nsg-workload-prod-001"
  resource_group_name           = "rg-workload-prod"
  location                      = "canadacentral"
  inherited_resource_group_tags = {}

  security_rules = {
    allow_https = {
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }

  tags = {
    Owner = "CCOE"
    IaC   = "Terraform"
  }
}

run "plan_nsg_with_rule" {
  command = plan

  assert {
    condition     = output.name == var.name && contains(output.security_rule_names, "allow_https")
    error_message = "NSG name or security rule was not propagated."
  }

  assert {
    condition     = output.tags.Owner == "CCOE" && !contains(keys(output.tags), "Environment")
    error_message = "NSG should preserve caller tags without adding module-generated tags."
  }
}

run "plan_subnet_and_nic_associations" {
  command = plan

  variables {
    subnet_ids = [
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-prod/subnets/snet-app"
    ]
    network_interface_ids = [
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-workload-prod/providers/Microsoft.Network/networkInterfaces/nic-app-001"
    ]
  }

  assert {
    condition     = length(output.subnet_association_ids) == 1 && length(output.network_interface_association_ids) == 1
    error_message = "Expected one subnet and one network interface association."
  }
}

run "reject_duplicate_rule_priority" {
  command = plan

  variables {
    security_rules = {
      first = {
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
      second = {
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    }
  }

  expect_failures = [
    var.security_rules,
  ]
}
