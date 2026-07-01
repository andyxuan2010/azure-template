# Function App Module

Provision an Azure Function App with secure defaults, standardized naming and tags, runtime stack configuration, storage authentication options, managed identity, networking, private endpoint, Easy Auth, backups, diagnostics, and RBAC.

## Features

- Linux and Windows Function Apps on an existing App Service Plan.
- Secure defaults: HTTPS-only, public network access disabled, FTP/WebDeploy basic publishing disabled, TLS 1.2 minimum, SCM restrictions aligned to the main site by default.
- Standard generated naming using `name_prefix`, `workload_name`, `app_env`, `location_code`, and optional random suffixes.
- Resource-group tag inheritance plus caller-provided tags, without module-generated marker tags.
- Storage authentication through access key, managed identity, or Key Vault secret ID.
- Optional storage account lookup only when an access key is required and not supplied.
- Runtime stacks for .NET, Java, Node, PowerShell, Python, custom handlers, and Linux containers.
- System-assigned and user-assigned identities, Key Vault reference identity, storage mounts, connection strings, sticky settings, backup configuration, and CORS.
- VNet integration, route-all, private endpoint with DNS zone IDs or DNS zone name lookup, static private IP configuration, manual approval, and private endpoint timeouts.
- Easy Auth v1 and Auth v2 support, including Microsoft Entra ID and custom OIDC providers.
- Built-in Contributor and Reader assignments for Entra groups, plus generic Function App-scoped RBAC assignments.
- Diagnostics to Log Analytics, Storage Account archive, and Event Hub, with category and category-group support.
- Mock-provider Terraform tests for fast plan coverage without creating live Azure resources.

## Basic Usage

```hcl
module "functionapp" {
  source = "./modules/functionapp"

  resource_group_name = "rg-platform-prod"
  location            = "canadacentral"
  name                = "func-orders-prod-cc-001"
  app_env             = "prod"

  service_plan_id      = module.appserviceplan.id
  storage_account_name = module.storageaccount.name

  application_stack = {
    dotnet_version              = "8.0"
    use_dotnet_isolated_runtime = true
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "dotnet-isolated"
    WEBSITE_RUN_FROM_PACKAGE = "1"
  }

  tags = {
    Owner = "Platform"
  }
}
```

## Private Function App

```hcl
module "functionapp" {
  source = "./modules/functionapp"

  resource_group_name           = "rg-platform-prod"
  location                      = "canadacentral"
  workload_name                 = "orders"
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

## Diagnostics And Auth

```hcl
module "functionapp" {
  source = "./modules/functionapp"

  resource_group_name = "rg-platform-prod"
  location            = "canadacentral"
  name                = "func-api-prod-cc-001"
  app_env             = "prod"

  service_plan_id             = module.appserviceplan.id
  storage_key_vault_secret_id = azurerm_key_vault_secret.function_storage.id

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

  enable_diagnostics             = true
  log_analytics_workspace_id     = module.log_analytics.id
  log_analytics_destination_type = "Dedicated"
  diagnostic_log_categories      = ["AllLogs"]
}
```

## Testing

Run module checks from the module directory:

```powershell
terraform init -backend=false
terraform validate
terraform test
```

`tests/live.tftest.hcl` uses Terraform mock providers, so it validates module behavior without creating live Azure resources.

The module rejects conflicting storage authentication modes, ambiguous IP
restriction sources, simultaneous Easy Auth v1/v2 configuration, and manual
private endpoint requests without an approval message.
