mock_provider "azurerm" {}
mock_provider "azuread" {}
mock_provider "random" {}

variables {
  resource_group_name = "rg-network-prod"
  location            = "canadacentral"
  inherited_resource_group_tags = {
    Owner          = "Network"
    application_id = "hub"
  }
  name          = "vnet-hub-prod"
  address_space = ["10.20.0.0/16"]
  subnets = {
    application = {
      address_prefixes  = ["10.20.1.0/24"]
      service_endpoints = ["Microsoft.Storage"]
    }
    private_endpoints = {
      address_prefixes                  = ["10.20.2.0/24"]
      private_endpoint_network_policies = "Disabled"
    }
  }
  app_admin_group = ["11111111-1111-1111-1111-111111111111"]
  app_user_group  = ["22222222-2222-2222-2222-222222222222"]
}

run "plan_vnet_subnets_and_rbac" {
  command = plan

  assert {
    condition     = azurerm_virtual_network.this.name == "vnet-hub-prod" && contains(azurerm_virtual_network.this.address_space, "10.20.0.0/16")
    error_message = "The VNet name or address space was not planned correctly."
  }

  assert {
    condition     = length(azurerm_subnet.this) == 2
    error_message = "Expected two subnets."
  }

  assert {
    condition     = azurerm_subnet.this["private_endpoints"].private_endpoint_network_policies == "Disabled"
    error_message = "Private endpoint subnet policy was not passed through."
  }

  assert {
    condition     = length(azurerm_role_assignment.app_admin_group) == 1 && length(azurerm_role_assignment.app_user_group) == 1
    error_message = "Expected one admin and one user role assignment."
  }

  assert {
    condition     = output.tags.Owner == "Network"
    error_message = "Plan-known inherited tags were not applied."
  }
}

run "plan_diagnostics" {
  command = plan

  variables {
    enable_diagnostics         = true
    log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-monitoring/providers/Microsoft.OperationalInsights/workspaces/log-platform"
  }

  assert {
    condition     = length(azurerm_monitor_diagnostic_setting.this) == 1
    error_message = "Enabling diagnostics must create one diagnostic setting."
  }
}
