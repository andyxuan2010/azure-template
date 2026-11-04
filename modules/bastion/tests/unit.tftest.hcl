mock_provider "azurerm" {}

variables {
  name                        = "bas-platform-cc-dev-001"
  resource_group_name         = "rg-platform-dev"
  location                    = "canadacentral"
  subnet_id                   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network-dev/providers/Microsoft.Network/virtualNetworks/vnet-platform/subnets/AzureBastionSubnet"
  inherit_resource_group_tags = false
  tags = {
    Owner = "CCOE"
  }
}

run "plan_basic_with_module_created_public_ip" {
  command = plan

  assert {
    condition     = output.name == var.name && output.sku == "Basic"
    error_message = "The Bastion host name or Basic SKU was not propagated."
  }

  assert {
    condition     = output.subnet_id == var.subnet_id && output.tags.Owner == "CCOE"
    error_message = "The Bastion subnet or caller tags were not propagated."
  }

  assert {
    condition     = length(azurerm_public_ip.this) == 1
    error_message = "The module should create a public IP when no existing ID is supplied."
  }
}

run "plan_with_existing_public_ip" {
  command = plan

  variables {
    public_ip_address_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network-dev/providers/Microsoft.Network/publicIPAddresses/pip-existing"
  }

  assert {
    condition     = output.public_ip_address_id == var.public_ip_address_id && length(azurerm_public_ip.this) == 0
    error_message = "The existing public IP should be used without creating another public IP."
  }
}

run "reject_basic_with_standard_feature" {
  command = plan

  variables {
    file_copy_enabled = true
  }

  expect_failures = [
    check.sku_feature_compatibility,
  ]
}
