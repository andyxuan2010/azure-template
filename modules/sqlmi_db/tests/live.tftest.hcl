mock_provider "azurerm" {
  mock_data "azurerm_mssql_managed_instance" {
    defaults = {
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-data-prod/providers/Microsoft.Sql/managedInstances/sqlmi-data-prod"
      name                = "sqlmi-data-prod"
      administrator_login = "sqladmin"
      fqdn                = "sqlmi-data-prod.database.windows.net"
      tags = {
        Owner = "Data"
      }
    }
  }
}

mock_provider "azuread" {}

variables {
  app_sqlmi       = "sqlmi-data-prod"
  app_sqlmi_db    = "orders"
  app_sqlmi_rg    = "rg-data-prod"
  app_admin_group = ["11111111-1111-1111-1111-111111111111"]
  app_user_group  = ["22222222-2222-2222-2222-222222222222"]
  tags = {
    CostCenter = "1234"
  }
}

run "plan_database_rbac" {
  command = plan

  assert {
    condition     = azurerm_mssql_managed_database.this.name == "orders"
    error_message = "The managed database name was not passed through."
  }

  assert {
    condition     = output.managed_database_tags.Owner == "Data" && output.managed_database_tags.CostCenter == "1234"
    error_message = "Database tags must merge managed-instance tags with caller tags."
  }

  assert {
    condition     = length(azurerm_role_assignment.app_admin_group) == 1 && length(azurerm_role_assignment.app_user_group) == 1
    error_message = "Expected one database role assignment for each supplied principal."
  }

  assert {
    condition     = output.diagnostics_enabled == false
    error_message = "Diagnostics should remain disabled by default."
  }
}

run "plan_diagnostics" {
  command = plan

  variables {
    enable_diagnostics         = true
    log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-monitoring/providers/Microsoft.OperationalInsights/workspaces/log-platform"
  }

  assert {
    condition     = length(azurerm_monitor_diagnostic_setting.this) == 1 && output.diagnostics_enabled
    error_message = "Enabling diagnostics must create one diagnostic setting."
  }
}
