terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.0, < 4.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

module "web_app" {
  source = "../.."

  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  app_service_plan_id           = var.app_service_plan_id
  kind                          = "Linux"
  app_env                       = "prod"
  inherit_resource_group_tags   = false
  inherited_resource_group_tags = {}

  system_assigned_identity_enabled = true
  public_network_access_enabled    = false
  enable_private_endpoint          = true
  private_endpoint_subnet_id       = var.private_endpoint_subnet_id
  private_dns_zone_id              = var.private_dns_zone_id
  virtual_network_subnet_id        = var.vnet_integration_subnet_id
  vnet_route_all_enabled           = true

  minimum_tls_version                            = "1.2"
  scm_minimum_tls_version                        = "1.2"
  ftps_state                                     = "Disabled"
  http2_enabled                                  = true
  ftp_publish_basic_authentication_enabled       = false
  webdeploy_publish_basic_authentication_enabled = false
  scm_basic_auth_publishing_credentials_enabled  = false
  health_check_path                              = "/health"
  health_check_eviction_time_in_min              = 5

  application_stack = {
    python_version = "3.12"
  }

  app_settings = {
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
  }

  enable_application_insights            = true
  application_insights_workspace_id      = var.log_analytics_workspace_id
  application_insights_retention_in_days = 90
  enable_diagnostics                     = true
  log_analytics_workspace_id             = var.log_analytics_workspace_id
  diagnostic_category_discovery_enabled  = false

  tags = {
    Environment    = "prod"
    Owner          = "Application Team"
    BusinessImpact = "High"
    DataClass      = "Internal"
  }
}
