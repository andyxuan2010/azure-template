provider "azurerm" {
  features {}
}

provider "azuread" {}

variables {
  resource_group_name = "rg-ba-eus-prd-shared-management"
  location            = "eastus"
  kind                = "Linux"
  os_type             = "Linux"
  sku_name            = "B1"
}

run "setup" {
  command = apply

  module {
    source = "./tests/setup"
  }

  variables {
    resource_group_name = var.resource_group_name
    location            = var.location
    os_type             = var.os_type
    sku_name            = var.sku_name
  }
}

run "apply" {
  command = apply

  variables {
    app_name            = run.setup.app_name
    resource_group_name = var.resource_group_name
    location            = var.location
    app_service_plan_id = run.setup.service_plan_id
    kind                = var.kind
    app_settings = {
      MY_SETTING      = "value"
      ANOTHER_SETTING = "value"
    }
    app_admin_group = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
    app_user_group  = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
    application_stack = {
      python_version = "3.11"
    }
    active_directory_client_id                   = ""
    auth_mode                                    = "none"
    allow_anonymous                              = true
    unauthenticated_action                       = "AllowAnonymous"
    virtual_network_subnet_id                    = ""
    vnet_route_all_enabled                       = false
    always_on                                    = true
    ftps_state                                   = "Disabled"
    http2_enabled                                = true
    use_32_bit_worker                            = false
    public_network_access_enabled                = false
    enable_application_insights                  = false
    diagnostic_setting_enabled_log_categories    = []
    diagnostic_setting_enabled_metric_categories = []
    diagnostic_setting_name                      = "audit-logs"
    app_env                                      = "prod"
    tags = {
      Environment = "Production"
      Owner       = "CCOE"
      IaC         = "Terraform"
    }
  }

  assert {
    condition     = output.app_name == run.setup.app_name
    error_message = "App Service did not use the App Service Plan test fixture inputs as expected."
  }
}
