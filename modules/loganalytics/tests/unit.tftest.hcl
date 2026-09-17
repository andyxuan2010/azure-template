mock_provider "azurerm" {}

variables {
  name                = "law-platform-dev"
  resource_group_name = "rg-platform-dev"
  location            = "canadacentral"
  retention_in_days   = 30
  inherited_resource_group_tags = {
    CostCenter = "platform"
  }
}

run "plan" {
  command = plan

  assert {
    condition     = output.name == var.name
    error_message = "Log Analytics workspace name output did not match input."
  }

  assert {
    condition     = output.merged_tags.CostCenter == "platform"
    error_message = "Inherited resource-group tags were not applied."
  }
}

run "plan_governance_controls" {
  command = plan

  variables {
    sku                                     = "CapacityReservation"
    reservation_capacity_in_gb_per_day      = 100
    local_authentication_disabled           = true
    allow_resource_only_permissions         = false
    immediate_data_purge_on_30_days_enabled = true
    data_collection_rule_id                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-monitor/providers/Microsoft.Insights/dataCollectionRules/dcr-platform"
    identity = {
      type = "SystemAssigned"
    }
  }

  assert {
    condition     = azurerm_log_analytics_workspace.this.local_authentication_enabled == false
    error_message = "Local authentication should be disabled."
  }

  assert {
    condition     = length(azurerm_log_analytics_workspace.this.identity) == 1
    error_message = "A system-assigned identity should be planned."
  }
}
