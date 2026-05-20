# App Service Examples

These examples use the standardized `appservice` module interface and assume the App Service Plan, resource group, and optional observability/networking dependencies already exist.

## Minimal Linux App

```hcl
module "appservice" {
  source = "./modules/appservice"

  app_name            = "app-contoso-dev-001"
  resource_group_name = "rg-contoso-dev-001"
  location            = "eastus"
  app_service_plan_id = azurerm_service_plan.this.id
  kind                = "Linux"
  app_env             = "dev"

  application_stack = {
    python_version = "3.11"
  }

  tags = {
    Owner = "CCOE"
    IaC   = "Terraform"
  }
}
```

## Production Hardened Linux App

```hcl
module "appservice" {
  source = "./modules/appservice"

  app_name            = "app-contoso-prod-001"
  resource_group_name = "rg-contoso-prod-001"
  location            = "eastus"
  app_service_plan_id = azurerm_service_plan.this.id
  kind                = "Linux"
  app_env             = "prod"

  application_stack = {
    node_version = "20-lts"
  }

  always_on                     = true
  ftps_state                    = "Disabled"
  http2_enabled                 = true
  minimum_tls_version           = "1.2"
  scm_minimum_tls_version       = "1.2"
  public_network_access_enabled = false
  vnet_route_all_enabled        = true
  scm_use_main_ip_restriction   = true

  ip_restrictions = [
    {
      name        = "AzureFrontDoor"
      priority    = 100
      action      = "Allow"
      service_tag = "AzureFrontDoor.Backend"
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

  enable_diagnostics             = true
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.this.id
  log_analytics_destination_type = "Dedicated"

  tags = {
    Owner = "CCOE"
    IaC   = "Terraform"
  }
}
```

## Easy Auth With Microsoft Entra ID

```hcl
module "appservice" {
  source = "./modules/appservice"

  app_name            = "app-contoso-prod-auth"
  resource_group_name = "rg-contoso-prod-001"
  location            = "eastus"
  app_service_plan_id = azurerm_service_plan.this.id
  kind                = "Linux"
  app_env             = "prod"

  auth_mode                  = "easy_auth"
  active_directory_client_id = azuread_application.this.client_id

  active_directory_allowed_groups = [
    azuread_group.app_users.object_id
  ]

  app_settings = {
    MICROSOFT_PROVIDER_AUTHENTICATION_SECRET = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.auth_secret.id})"
  }

  system_assigned_identity_enabled = true
  key_vault_reference_identity_id  = azurerm_user_assigned_identity.kv.id
}
```

## Windows App With Private Endpoint

```hcl
module "appservice" {
  source = "./modules/appservice"

  app_name            = "app-contoso-prod-win"
  resource_group_name = "rg-contoso-prod-001"
  location            = "eastus"
  app_service_plan_id = azurerm_service_plan.windows.id
  kind                = "Windows"
  app_env             = "prod"

  application_stack = {
    current_stack  = "dotnet"
    dotnet_version = "v8.0"
  }

  enable_private_endpoint         = true
  public_network_access_enabled   = false
  private_endpoint_subnet_id      = azurerm_subnet.private_endpoints.id
  private_dns_zone_id             = azurerm_private_dns_zone.webapp.id
  enable_diagnostics              = true
  diagnostic_storage_account_id   = azurerm_storage_account.audit.id
  log_analytics_workspace_id      = azurerm_log_analytics_workspace.this.id
}
```

## Notes

- Use the exact `serverFarms` casing in literal App Service Plan IDs; AzureRM validates that segment.
- Set `diagnostic_category_discovery_enabled = true` only when you want Azure category discovery at plan/apply time.
- Prefer Entra object IDs over display names for `app_admin_group` and `app_user_group` when group names are duplicated.
- Related test coverage lives in `tests/live.tftest.hcl` and runs plan-only scenarios.
