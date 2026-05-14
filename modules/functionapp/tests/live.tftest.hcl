provider "azurerm" {
  features {}
}

provider "azuread" {}

variables {
  resource_group_name = "rg-ba-eus-prd-shared-management"
  location            = "eastus"
  os_type             = "Windows"
  sku_name            = "B1"
}

run "setup" {
  command = apply

  module {
    source = "./tests/setup"
  }
}

run "apply" {
  command = apply

  variables {
    resource_group_name                 = "rg-ba-eus-prd-shared-management"
    location                            = "eastus"
    name                                = run.setup.function_app_name
    os_type                             = "Windows"
    service_plan_id                     = run.setup.service_plan_id
    storage_account_name                = "stccoeiacprod"
    storage_account_resource_group_name = "rg-ccoe-iac-cc-prod"
    storage_uses_managed_identity       = false
    functions_extension_version         = "~4"
    builtin_logging_enabled             = false
    https_only                          = true
    public_network_access_enabled       = false
    app_settings = {
      FUNCTIONS_WORKER_RUNTIME = "dotnet"
      WEBSITE_RUN_FROM_PACKAGE = "1"
    }
    app_admin_group    = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
    app_user_group     = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
    connection_strings = []
    application_stack = {
      dotnet_version = "v8.0"
    }
    system_assigned_identity_enabled             = true
    identity_ids                                 = []
    key_vault_reference_identity_id              = ""
    virtual_network_subnet_id                    = ""
    vnet_integration_subnet_name                 = ""
    vnet_integration_vnet_name                   = ""
    vnet_integration_network_resource_group_name = ""
    vnet_route_all_enabled                       = false
    always_on                                    = true
    ftps_state                                   = "Disabled"
    http2_enabled                                = true
    minimum_tls_version                          = "1.2"
    use_32_bit_worker                            = false
    health_check_path                            = null
    health_check_eviction_time_in_min            = null
    runtime_scale_monitoring_enabled             = false
    daily_memory_time_quota                      = null
    zip_deploy_file                              = null
    sticky_settings_app_setting_names            = []
    sticky_settings_connection_string_names      = []
    enable_private_endpoint                      = false
    private_endpoint_subnet_id                   = ""
    private_endpoint_subnet_name                 = ""
    private_endpoint_vnet_name                   = ""
    private_endpoint_network_resource_group_name = ""
    private_dns_zone_id                          = ""
    private_dns_zone_name                        = ""
    private_dns_zone_resource_group_name         = ""
    enable_diagnostics                           = false
    diagnostic_log_categories                    = ["AppServiceHTTPLogs", "AppServiceConsoleLogs", "AppServiceAppLogs", "AppServiceAuditLogs", "AppServiceIPSecAuditLogs", "AppServicePlatformLogs"]
    diagnostic_metric_categories                 = ["AllMetrics"]
    tags = {
      Environment = "Production"
      Owner       = "CCOE"
      IaC         = "Terraform"
    }
  }

  assert {
    condition     = output.service_plan_id == run.setup.service_plan_id
    error_message = "Function App did not receive the App Service Plan ID created by the setup run."
  }
}
