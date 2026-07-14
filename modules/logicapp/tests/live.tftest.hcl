mock_provider "azurerm" {
  mock_data "azurerm_storage_account" {
    defaults = {
      id                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-logic/providers/Microsoft.Storage/storageAccounts/stlogic001"
      name               = "stlogic001"
      primary_access_key = "ZmFrZS1zdG9yYWdlLWtleQ=="
    }
  }
}

mock_provider "azuread" {}

variables {
  resource_group_name           = "rg-logic-prod"
  location                      = "canadacentral"
  inherited_resource_group_tags = {}
  name                          = "logic-orders-prod-001"
  service_plan_id               = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-logic-prod/providers/Microsoft.Web/serverFarms/asp-logic-prod-001"
  storage_account_name          = "stlogic001"
  app_admin_group               = []
  app_user_group                = []

  tags = {
    Owner = "CCOE"
    IaC   = "Terraform"
  }
}

run "plan_secure_baseline" {
  command = plan

  assert {
    condition     = output.name == var.name && output.location == var.location
    error_message = "Logic App name or location was not propagated."
  }

  assert {
    condition     = output.tags.Owner == "CCOE" && output.tags.IaC == "Terraform" && !contains(keys(output.tags), "Environment")
    error_message = "Logic App should preserve caller tags without adding module-generated tags."
  }
}

run "plan_identity_private_endpoint_and_diagnostics" {
  command = plan

  variables {
    system_assigned_identity_enabled = true
    enable_private_endpoint          = true
    private_endpoint_subnet_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-prod/subnets/snet-private-endpoints"
    private_dns_zone_id              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.azurewebsites.net"
    enable_diagnostics               = true
    log_analytics_workspace_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-monitor/providers/Microsoft.OperationalInsights/workspaces/log-prod"
  }

  assert {
    condition     = output.private_endpoint_enabled && output.diagnostics_enabled && output.identity_type == "SystemAssigned"
    error_message = "Private endpoint and diagnostics should be planned."
  }
}

run "reject_route_all_without_vnet" {
  command = plan

  variables {
    vnet_route_all_enabled = true
  }

  expect_failures = [
    check.logicapp_input_consistency,
  ]
}

run "reject_duplicate_connection_strings" {
  command = plan

  variables {
    connection_strings = [
      {
        name  = "Api"
        value = "one"
      },
      {
        name  = "api"
        value = "two"
      }
    ]
  }

  expect_failures = [
    var.connection_strings,
  ]
}
