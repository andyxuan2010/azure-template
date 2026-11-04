mock_provider "azurerm" {}

variables {
  name                        = "nat-platform-cc-dev-001"
  resource_group_name         = "rg-network-dev"
  location                    = "canadacentral"
  subnet_ids                  = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network-dev/providers/Microsoft.Network/virtualNetworks/vnet-platform/subnets/snet-app"]
  inherit_resource_group_tags = false
  tags = {
    Owner = "CCOE"
  }
}

run "plan_standard_with_managed_public_ip" {
  command = plan

  assert {
    condition     = output.name == var.name && output.sku_name == "Standard"
    error_message = "NAT Gateway name or Standard SKU was not propagated."
  }

  assert {
    condition     = length(azurerm_public_ip.this) == 1 && length(output.public_ip_association_ids) == 1
    error_message = "The default plan should create and associate one public IP."
  }

  assert {
    condition     = length(output.subnet_association_ids) == 1 && output.tags.Owner == "CCOE"
    error_message = "The subnet association or caller tags were not propagated."
  }
}

run "plan_with_existing_public_ips" {
  command = plan

  variables {
    public_ip_address_ids = [
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network-dev/providers/Microsoft.Network/publicIPAddresses/pip-one",
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network-dev/providers/Microsoft.Network/publicIPAddresses/pip-two",
    ]
  }

  assert {
    condition     = length(azurerm_public_ip.this) == 0 && length(output.public_ip_association_ids) == 2
    error_message = "Caller-owned public IPs should be associated without creating new IP resources."
  }
}

run "plan_standard_v2" {
  command = plan

  variables {
    sku_name = "StandardV2"
  }

  assert {
    condition     = output.sku_name == "StandardV2"
    error_message = "StandardV2 should be passed to the NAT Gateway resource."
  }
}

run "reject_zones_for_standard_v2" {
  command = plan

  variables {
    sku_name = "StandardV2"
    zones    = ["1"]
  }

  expect_failures = [
    var.zones,
  ]
}
