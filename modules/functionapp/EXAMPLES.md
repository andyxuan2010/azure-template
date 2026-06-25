# Function App Examples

## Linux Function With Generated Name

```hcl
module "functionapp" {
  source = "./modules/functionapp"

  resource_group_name = "rg-platform-dev"
  location            = "canadacentral"
  workload_name       = "orders"
  app_env             = "dev"
  use_random_suffix   = false
  instance            = "001"

  service_plan_id      = module.appserviceplan.id
  storage_account_name = module.storageaccount.name

  application_stack = {
    python_version = "3.11"
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "python"
    WEBSITE_RUN_FROM_PACKAGE = "1"
  }
}
```

## Managed Identity Storage And Private Endpoint

```hcl
module "functionapp" {
  source = "./modules/functionapp"

  resource_group_name           = "rg-platform-prod"
  location                      = "canadacentral"
  name                          = "func-orders-prod-cc-001"
  app_env                       = "prod"
  public_network_access_enabled = false

  service_plan_id               = module.appserviceplan.id
  storage_account_name          = module.storageaccount.name
  storage_uses_managed_identity = true

  system_assigned_identity_enabled = true
  virtual_network_subnet_id        = module.vnet.subnet_ids["snet-functions"]
  vnet_route_all_enabled           = true

  enable_private_endpoint    = true
  private_endpoint_subnet_id = module.vnet.subnet_ids["snet-private-endpoints"]
  private_dns_zone_ids       = [module.private_dns.zone_ids["privatelink.azurewebsites.net"]]
}
```

## Windows .NET Isolated With Diagnostics

```hcl
module "functionapp" {
  source = "./modules/functionapp"

  resource_group_name = "rg-platform-prod"
  location            = "canadacentral"
  name                = "func-billing-prod-cc-001"
  app_env             = "prod"
  os_type             = "Windows"

  service_plan_id      = module.appserviceplan.id
  storage_account_name = module.storageaccount.name

  application_stack = {
    dotnet_version              = "v8.0"
    use_dotnet_isolated_runtime = true
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "dotnet-isolated"
    WEBSITE_RUN_FROM_PACKAGE = "1"
  }

  enable_diagnostics             = true
  log_analytics_workspace_id     = module.log_analytics.id
  log_analytics_destination_type = "Dedicated"
  diagnostic_log_categories      = ["AllLogs"]
}
```

## Key Vault Storage Secret And Easy Auth

```hcl
module "functionapp" {
  source = "./modules/functionapp"

  resource_group_name = "rg-platform-prod"
  location            = "canadacentral"
  name                = "func-api-prod-cc-001"
  app_env             = "prod"

  service_plan_id             = module.appserviceplan.id
  storage_key_vault_secret_id = azurerm_key_vault_secret.function_storage.id

  system_assigned_identity_enabled = true

  application_stack = {
    node_version = "20"
  }

  auth_settings_v2 = {
    default_provider       = "azureactivedirectory"
    require_authentication = true
    unauthenticated_action = "RedirectToLoginPage"
    active_directory_v2 = {
      client_id            = azuread_application.function.client_id
      tenant_auth_endpoint = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/v2.0"
    }
  }
}
```

## Linux Container With Managed Identity Image Pull

```hcl
module "functionapp" {
  source = "./modules/functionapp"

  resource_group_name = "rg-platform-prod"
  location            = "canadacentral"
  name                = "func-worker-prod-cc-001"
  app_env             = "prod"

  service_plan_id      = module.appserviceplan.id
  storage_account_name = module.storageaccount.name

  identity_ids = [azurerm_user_assigned_identity.function.id]

  application_stack = {
    docker = {
      image_name   = "functions/worker"
      image_tag    = "1.0.0"
      registry_url = "https://contoso.azurecr.io"
    }
  }

  container_registry_use_managed_identity       = true
  container_registry_managed_identity_client_id = azurerm_user_assigned_identity.function.client_id
  vnet_image_pull_enabled                       = true
}
```

## Additional RBAC

```hcl
module "functionapp" {
  source = "./modules/functionapp"

  resource_group_name = "rg-platform-prod"
  location            = "canadacentral"
  name                = "func-jobs-prod-cc-001"

  service_plan_id      = module.appserviceplan.id
  storage_account_name = module.storageaccount.name

  app_admin_group = ["11111111-1111-1111-1111-111111111111"]
  app_user_group  = ["22222222-2222-2222-2222-222222222222"]

  role_assignments = {
    support_reader = {
      principal_id         = "33333333-3333-3333-3333-333333333333"
      principal_type       = "Group"
      role_definition_name = "Reader"
    }
  }
}
```

## Notes

- Prefer managed identity or a Key Vault storage secret for production storage authentication.
- Supply `storage_account_access_key` only when you intentionally want to avoid the storage account data-source lookup, such as in isolated plan tests.
- Prefer Entra object IDs over display names when group names are duplicated.
- When public access is enabled, pair it with `ip_restriction_default_action = "Deny"` and explicit allow rules.
- Storage access-key, managed-identity, and Key Vault secret modes are mutually exclusive.
- Each IP restriction must set exactly one of `ip_address`, `service_tag`, or `virtual_network_subnet_id`.
- Configure either `auth_settings` or `auth_settings_v2`, not both.
