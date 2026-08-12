mock_provider "azurerm" {}

mock_provider "azurerm" {
  alias = "prod"

  mock_data "azurerm_subnet" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-platform/subnets/snet-private-endpoints"
    }
  }

  mock_data "azurerm_private_dns_zone" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
    }
  }
}

variables {
  name                           = "pep-platform-cc-dev-001"
  resource_group_name            = "rg-platform-dev"
  location                       = "canadacentral"
  inherited_resource_group_tags  = {}
  subnet_id                      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-platform/subnets/snet-private-endpoints"
  private_connection_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-platform-dev/providers/Microsoft.Storage/storageAccounts/stplatformccdev001"
  subresource_names              = ["blob"]
  private_dns_zone_ids           = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"]

  tags = {
    Owner = "CCOE"
    IaC   = "Terraform"
  }
}

run "plan_private_endpoint_with_dns" {
  command = plan

  assert {
    condition     = output.name == var.name && output.subnet_id == var.subnet_id
    error_message = "Private Endpoint name or subnet ID was not propagated."
  }

  assert {
    condition     = length(output.private_dns_zone_ids) == 1 && output.tags.Owner == "CCOE"
    error_message = "Private DNS zone IDs or tags were not propagated."
  }
}

run "plan_generated_name_without_dns" {
  command = plan

  variables {
    name                 = ""
    workload             = "platform"
    app_env              = "dev"
    instance             = "002"
    private_dns_zone_ids = []
  }

  assert {
    condition     = output.name == "pep-platform-cc-dev-002" && length(output.private_dns_zone_ids) == 0
    error_message = "Generated Private Endpoint name or empty DNS configuration did not match expectations."
  }
}

run "plan_shared_network_lookups" {
  command = plan

  variables {
    subnet_id                            = ""
    subnet_name                          = "snet-private-endpoints"
    virtual_network_name                 = "vnet-platform"
    virtual_network_resource_group_name  = "rg-network"
    private_dns_zone_ids                 = []
    private_dns_zone_names               = ["privatelink.blob.core.windows.net"]
    private_dns_zone_resource_group_name = "rg-dns"
  }

  assert {
    condition     = output.subnet_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-platform/subnets/snet-private-endpoints"
    error_message = "The shared-network subnet lookup did not resolve through azurerm.prod."
  }

  assert {
    condition     = length(output.private_dns_zone_ids) == 1
    error_message = "The shared Private DNS zone lookup did not resolve through azurerm.prod."
  }
}

run "reject_missing_subnet_lookup_inputs" {
  command = plan

  variables {
    subnet_id            = ""
    subnet_name          = ""
    virtual_network_name = ""
  }

  expect_failures = [
    check.private_endpoint_input_consistency,
  ]
}
