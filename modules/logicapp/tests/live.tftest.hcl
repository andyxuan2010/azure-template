provider "azurerm" {
  features {}
}

provider "azuread" {}

variables {
  resource_group_name = "rg-logic-iactest"
  location            = "eastus"
  sku_name            = "WS1"
}

run "setup" {
  command = apply

  module {
    source = "./tests/setup"
  }

  variables {
    resource_group_name = var.resource_group_name
    location            = var.location
    sku_name            = var.sku_name
  }
}

run "apply" {
  command = apply

  variables {
    resource_group_name                           = run.setup.resource_group_name
    location                                      = var.location
    name                                          = run.setup.logic_app_name
    service_plan_id                               = run.setup.service_plan_id
    storage_account_name                          = run.setup.storage_account_name
    storage_account_resource_group_name           = run.setup.resource_group_name
    storage_account_share_name                    = null
    app_settings                                  = {}
    connection_strings                            = []
    app_admin_group                               = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
    app_user_group                                = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
    system_assigned_identity_enabled              = true
    identity_ids                                  = []
    virtual_network_subnet_id                     = ""
    vnet_integration_subnet_name                  = ""
    vnet_integration_vnet_name                    = ""
    vnet_integration_network_resource_group_name  = ""
    vnet_route_all_enabled                        = false
    enabled                                       = true
    https_only                                    = true
    public_network_access_enabled                 = false
    client_affinity_enabled                       = false
    client_certificate_mode                       = "Required"
    ftp_publish_basic_authentication_enabled      = false
    scm_basic_auth_publishing_credentials_enabled = false
    always_on                                     = true
    ftps_state                                    = "Disabled"
    http2_enabled                                 = true
    minimum_tls_version                           = "1.2"
    use_32_bit_worker_process                     = false
    health_check_path                             = null
    runtime_scale_monitoring_enabled              = false
    websockets_enabled                            = false
    use_extension_bundle                          = null
    bundle_version                                = null
    logic_app_version                             = null
    enable_private_endpoint                       = false
    private_endpoint_subnet_id                    = ""
    private_endpoint_subnet_name                  = ""
    private_endpoint_vnet_name                    = ""
    private_endpoint_network_resource_group_name  = ""
    private_dns_zone_id                           = ""
    private_dns_zone_name                         = ""
    private_dns_zone_resource_group_name          = ""
    enable_diagnostics                            = false
    log_analytics_workspace_id                    = ""
    diagnostic_log_categories                     = ["AppServiceHTTPLogs", "AppServiceConsoleLogs", "AppServiceAppLogs", "AppServiceAuditLogs", "AppServiceIPSecAuditLogs", "AppServicePlatformLogs"]
    diagnostic_metric_categories                  = ["AllMetrics"]
    tags = {
      Environment = "Production"
      Owner       = "CCOE"
      IaC         = "Terraform"
    }
  }

  assert {
    condition     = output.service_plan_id == run.setup.service_plan_id
    error_message = "Logic App Standard did not receive the App Service Plan ID created by the setup run."
  }

  assert {
    condition     = output.storage_account_id == run.setup.storage_account_id
    error_message = "Logic App Standard did not use the storage account created by the setup run."
  }
}
