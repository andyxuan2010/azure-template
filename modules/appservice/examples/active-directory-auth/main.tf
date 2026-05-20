provider "azurerm" {
  features {}
}

resource "random_id" "this" {
  byte_length = 8
}

module "log_analytics" {
  source = "github.com/equinor/terraform-azurerm-log-analytics?ref=v1.4.0"

  workspace_name      = "log-${random_id.this.hex}"
  resource_group_name = var.resource_group_name
  location            = var.location
}

module "app_service" {
  source = "github.com/equinor/terraform-azurerm-app-service?ref=v1.0.0"

  plan_name           = "plan-${random_id.this.hex}"
  resource_group_name = var.resource_group_name
  location            = var.location
}

module "web_app" {
  source = "../.."
  providers = {
    azurerm = azurerm
  }

  app_name                   = "app-${random_id.this.hex}"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  app_service_plan_id        = module.app_service.plan_id
  log_analytics_workspace_id = module.log_analytics.workspace_id

  active_directory_client_id                  = var.active_directory_client_id
  active_directory_client_secret_setting_name = var.active_directory_client_secret_setting_name
  active_directory_tenant_auth_endpoint       = var.active_directory_tenant_auth_endpoint
  active_directory_login_parameters           = var.active_directory_login_parameters

  # Store client secret as an app setting and prefer Key Vault references.
  app_settings = {
    (var.active_directory_client_secret_setting_name) = "@Microsoft.KeyVault(SecretUri=https://<key-vault-name>.vault.azure.net/secrets/<secret-name>/<secret-version>)"
  }
}
