provider "azurerm" {
  features {}
}

provider "azuread" {}

variables {
  resource_group_name = "rg-ba-eus-prd-shared-management"
  location            = "eastus"
  name                = "dbw-iactest-prod-001"
  sku                 = "premium"

  managed_resource_group_name                         = ""
  public_network_access_enabled                       = true
  network_security_group_rules_required               = "AllRules"
  customer_managed_key_enabled                        = false
  infrastructure_encryption_enabled                   = false
  default_storage_firewall_enabled                    = false
  access_connector_id                                 = ""
  load_balancer_backend_address_pool_id               = ""
  managed_disk_cmk_key_vault_id                       = ""
  managed_disk_cmk_key_vault_key_id                   = ""
  managed_disk_cmk_rotation_to_latest_version_enabled = false
  managed_services_cmk_key_vault_id                   = ""
  managed_services_cmk_key_vault_key_id               = ""
  custom_parameters                                   = null
  enhanced_security_compliance                        = null
  app_admin_group                                     = []
  app_user_group                                      = []
  enable_diagnostics                                  = false
  log_analytics_workspace_id                          = ""
  diagnostic_log_categories                           = []
  diagnostic_metric_categories                        = ["AllMetrics"]
  tags = {
    Environment = "Production"
    Owner       = "CCOE"
    IaC         = "Terraform"
  }
}

run "plan" {
  command = plan

  assert {
    condition     = output.name == var.name
    error_message = "Databricks workspace test name was not propagated to the module."
  }

  assert {
    condition     = output.merged_tags.module == "databricks"
    error_message = "Databricks merged tags did not include the module marker."
  }
}
