mock_provider "azurerm" {
  mock_data "azurerm_client_config" {
    defaults = {
      tenant_id = "00000000-0000-0000-0000-000000000003"
    }
  }

  mock_data "azurerm_subnet" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network-prod/providers/Microsoft.Network/virtualNetworks/vnet-iactest-prod-001/subnets/snet-private-endpoints"
    }
  }

  mock_data "azurerm_private_dns_zone" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns-prod/providers/Microsoft.Network/privateDnsZones/privatelink.azurewebsites.net"
    }
  }
}
mock_provider "azuread" {}

variables {
  app_name            = "app-iactest-prod-001"
  app_env             = "prod"
  resource_group_name = "rg-ccoe-iac-cc-dev"
  location            = "canadacentral"
  app_service_plan_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ccoe-iac-cc-dev/providers/Microsoft.Web/serverFarms/asp-iactest-prod-001"
  kind                = "Linux"
  auth_mode           = "none"
  app_admin_group     = []
  app_user_group      = []
  inherited_resource_group_tags = {
    CostCenter = "platform"
  }

  diagnostic_setting_enabled_log_categories    = []
  diagnostic_setting_enabled_metric_categories = []

  tags = {
    Environment = "Production"
    Owner       = "CCOE"
    IaC         = "Terraform"
  }
}

run "plan_linux_baseline" {
  command = plan

  assert {
    condition     = output.app_name == var.app_name
    error_message = "Web App name output did not match input."
  }

  assert {
    condition     = output.app_kind == "Linux"
    error_message = "Linux plan should report Linux app kind."
  }

  assert {
    condition     = !contains(keys(output.merged_tags), "module")
    error_message = "Merged tags should not include the module marker."
  }

  assert {
    condition     = output.diagnostics_enabled == false
    error_message = "Diagnostics should be disabled when no destination is configured."
  }

  assert {
    condition     = output.merged_tags["CostCenter"] == "platform"
    error_message = "Inherited resource-group tags were not applied."
  }

  assert {
    condition     = azurerm_linux_web_app.this[0].site_config[0].scm_use_main_ip_restriction == false
    error_message = "SCM/Kudu endpoint should not reuse main site IP restrictions by default."
  }

  assert {
    condition     = azurerm_linux_web_app.this[0].site_config[0].scm_ip_restriction_default_action == "Allow"
    error_message = "SCM/Kudu endpoint should allow unmatched traffic by default to match Azure portal behavior."
  }
}

run "plan_linux_scm_use_main_override" {
  command = plan

  variables {
    app_name                         = "app-iactest-prod-005"
    app_env                          = "prod"
    resource_group_name              = "rg-ccoe-iac-cc-dev"
    location                         = "canadacentral"
    app_service_plan_id              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ccoe-iac-cc-dev/providers/Microsoft.Web/serverFarms/asp-iactest-prod-001"
    kind                             = "Linux"
    auth_mode                        = "none"
    app_admin_group                  = []
    app_user_group                   = []
    scmIpSecurityRestrictionsUseMain = true

    diagnostic_setting_enabled_log_categories    = []
    diagnostic_setting_enabled_metric_categories = []

    tags = {
      Environment = "Production"
      Owner       = "CCOE"
      IaC         = "Terraform"
    }
  }

  assert {
    condition     = azurerm_linux_web_app.this[0].site_config[0].scm_use_main_ip_restriction == true
    error_message = "scmIpSecurityRestrictionsUseMain should enable reuse of main site IP restrictions."
  }
}

run "plan_linux_hardened_options" {
  command = plan

  variables {
    app_name            = "app-iactest-prod-002"
    app_env             = "prod"
    resource_group_name = "rg-ccoe-iac-cc-dev"
    location            = "canadacentral"
    app_service_plan_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ccoe-iac-cc-dev/providers/Microsoft.Web/serverFarms/asp-iactest-prod-001"
    kind                = "Linux"
    auth_mode           = "none"
    app_admin_group     = []
    app_user_group      = []

    app_settings = {
      MY_SETTING = "value"
    }

    application_stack = {
      python_version = "3.11"
    }

    always_on                          = true
    ftps_state                         = "Disabled"
    http2_enabled                      = true
    minimum_tls_version                = "1.2"
    scm_minimum_tls_version            = "1.2"
    public_network_access_enabled      = false
    vnet_route_all_enabled             = true
    scm_use_main_ip_restriction        = true
    client_certificate_enabled         = true
    client_certificate_mode            = "Optional"
    client_certificate_exclusion_paths = "/healthz"

    ip_restrictions = [
      {
        name        = "AzureFrontDoor"
        priority    = 100
        service_tag = "AzureFrontDoor.Backend"
        action      = "Allow"
      }
    ]

    auto_heal_setting = {
      action = {
        action_type = "Recycle"
      }
      trigger = {
        requests = {
          count    = 100
          interval = "00:05:00"
        }
        status_code = [
          {
            count             = 10
            interval          = "00:05:00"
            status_code_range = "500-599"
          }
        ]
      }
    }

    diagnostic_setting_enabled_log_categories    = []
    diagnostic_setting_enabled_metric_categories = []

    tags = {
      Environment = "Production"
      Owner       = "CCOE"
      IaC         = "Terraform"
    }
  }

  assert {
    condition     = output.app_enabled == true
    error_message = "Web App should be enabled by default."
  }

  assert {
    condition     = output.auth_config.easy_auth_enabled == false
    error_message = "Easy Auth should be disabled when auth_mode is none."
  }
}

run "plan_easy_auth_and_diagnostics" {
  command = plan

  variables {
    app_name            = "app-iactest-prod-003"
    app_env             = "prod"
    resource_group_name = "rg-ccoe-iac-cc-dev"
    location            = "canadacentral"
    app_service_plan_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ccoe-iac-cc-dev/providers/Microsoft.Web/serverFarms/asp-iactest-prod-001"
    kind                = "Linux"
    app_admin_group     = []
    app_user_group      = []

    auth_mode                  = "easy_auth"
    active_directory_client_id = "11111111-1111-1111-1111-111111111111"
    active_directory_allowed_groups = [
      "22222222-2222-2222-2222-222222222222"
    ]
    active_directory_allowed_audiences = [
      "api://11111111-1111-1111-1111-111111111111"
    ]

    enable_diagnostics             = true
    log_analytics_workspace_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ccoe-iac-cc-dev/providers/Microsoft.OperationalInsights/workspaces/log-iactest-prod-001"
    log_analytics_destination_type = "Dedicated"
    diagnostic_storage_account_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ccoe-iac-cc-dev/providers/Microsoft.Storage/storageAccounts/stiactestprod001"
    diagnostic_setting_enabled_log_categories = [
      "AppServiceHTTPLogs",
      "AppServiceConsoleLogs"
    ]
    diagnostic_setting_enabled_metric_categories = [
      "AllMetrics"
    ]

    tags = {
      Environment = "Production"
      Owner       = "CCOE"
      IaC         = "Terraform"
    }
  }

  assert {
    condition     = output.auth_config.easy_auth_enabled == true
    error_message = "Easy Auth should be enabled when auth_mode is easy_auth."
  }

  assert {
    condition     = output.diagnostics_enabled == true
    error_message = "Diagnostics should be enabled when a destination and categories are configured."
  }

  assert {
    condition     = contains(output.diagnostic_metric_categories, "AllMetrics")
    error_message = "Diagnostics should include AllMetrics."
  }
}

run "plan_windows_private_endpoint" {
  command = plan

  variables {
    app_name            = "app-iactest-prod-004"
    app_env             = "prod"
    resource_group_name = "rg-ccoe-iac-cc-dev"
    location            = "canadacentral"
    app_service_plan_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ccoe-iac-cc-dev/providers/Microsoft.Web/serverFarms/asp-iactest-prod-001"
    kind                = "Windows"
    auth_mode           = "none"
    app_admin_group     = []
    app_user_group      = []

    application_stack = {
      current_stack  = "dotnet"
      dotnet_version = "v8.0"
    }

    handler_mappings = [
      {
        extension             = ".handler"
        script_processor_path = "D:\\home\\site\\wwwroot\\handler.exe"
      }
    ]

    enable_private_endpoint       = true
    public_network_access_enabled = false
    private_endpoint_subnet_id    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ccoe-iac-cc-dev/providers/Microsoft.Network/virtualNetworks/vnet-iactest-prod-001/subnets/snet-private-endpoints"
    private_dns_zone_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ccoe-iac-cc-dev/providers/Microsoft.Network/privateDnsZones/privatelink.azurewebsites.net"

    diagnostic_setting_enabled_log_categories    = []
    diagnostic_setting_enabled_metric_categories = []

    tags = {
      Environment = "Production"
      Owner       = "CCOE"
      IaC         = "Terraform"
    }
  }

  assert {
    condition     = output.app_kind == "Windows"
    error_message = "Windows plan should report Windows app kind."
  }
}

run "plan_private_endpoint_name_lookup" {
  command = plan

  variables {
    app_name            = "app-iactest-prod-006"
    app_env             = "prod"
    resource_group_name = "rg-ccoe-iac-cc-dev"
    location            = "canadacentral"
    app_service_plan_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ccoe-iac-cc-dev/providers/Microsoft.Web/serverFarms/asp-iactest-prod-001"
    kind                = "Linux"
    auth_mode           = "none"

    enable_private_endpoint                      = true
    public_network_access_enabled                = false
    private_endpoint_subnet_name                 = "snet-private-endpoints"
    private_endpoint_vnet_name                   = "vnet-iactest-prod-001"
    private_endpoint_network_resource_group_name = "rg-network-prod"
    private_dns_zone_name                        = "privatelink.azurewebsites.net"
    private_dns_zone_resource_group_name         = "rg-dns-prod"
    diagnostic_setting_enabled_log_categories    = []
    diagnostic_setting_enabled_metric_categories = []
  }

  assert {
    condition     = length(data.azurerm_subnet.private_endpoint) == 1
    error_message = "A null private_endpoint_subnet_id should allow subnet lookup by name."
  }

  assert {
    condition     = length(data.azurerm_private_dns_zone.webapp) == 1
    error_message = "A null private_dns_zone_id should allow private DNS zone lookup by name."
  }
}
