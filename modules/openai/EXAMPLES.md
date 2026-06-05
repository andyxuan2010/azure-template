# OpenAI Examples

## Secure Account With Generated Name

```hcl
module "openai" {
  source = "../openai"

  resource_group_name = "rg-platform-prod"
  location            = "canadacentral"
  workload_name       = "ai"
  app_env             = "prod"
  use_random_suffix   = false
  instance            = "001"

  tags = {
    Owner = "Platform"
  }
}
```

## Account With Model Deployments

```hcl
module "openai" {
  source = "../openai"

  resource_group_name = "rg-platform-prod"
  location            = "canadacentral"
  name                = "oai-platform-prod-cc-001"

  deployments = {
    "gpt4o-mini" = {
      model_format           = "OpenAI"
      model_name             = "gpt-4o-mini"
      model_version          = "2024-07-18"
      sku_name               = "Standard"
      sku_capacity           = 10
      version_upgrade_option = "OnceNewDefaultVersionAvailable"
    }
    "embedding-large" = {
      model_format = "OpenAI"
      model_name   = "text-embedding-3-large"
      sku_name     = "Standard"
      sku_capacity = 10
    }
  }
}
```

## Private Azure OpenAI Account

```hcl
module "openai" {
  source = "../openai"

  resource_group_name           = "rg-platform-prod"
  location                      = "canadacentral"
  name                          = "oai-platform-prod-cc-001"
  public_network_access_enabled = false

  enable_private_endpoint    = true
  private_endpoint_subnet_id = module.vnet.subnet_ids["snet-private-endpoints"]
  private_dns_zone_ids       = [module.private_dns.zone_ids["privatelink.openai.azure.com"]]

  network_acls = {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
}
```

## Private DNS Zone Lookup

```hcl
module "openai" {
  source = "../openai"

  resource_group_name = "rg-platform-prod"
  location            = "canadacentral"
  name                = "oai-platform-prod-cc-001"

  enable_private_endpoint                  = true
  private_endpoint_subnet_id               = module.vnet.subnet_ids["snet-private-endpoints"]
  private_dns_zone_names                   = ["privatelink.openai.azure.com"]
  private_dns_zone_resource_group_name     = "rg-platform-dns"
  private_endpoint_network_interface_name  = "nic-pep-oai-platform-prod-cc-001"
}
```

## Customer-Managed Key With User-Assigned Identity

```hcl
module "openai" {
  source = "../openai"

  resource_group_name = "rg-platform-prod"
  location            = "canadacentral"
  name                = "oai-platform-cmk-prod-cc-001"

  identity_ids = [azurerm_user_assigned_identity.openai.id]

  customer_managed_key = {
    key_vault_key_id   = azurerm_key_vault_key.openai.id
    identity_client_id = azurerm_user_assigned_identity.openai.client_id
  }
}
```

## Diagnostics And RBAC

```hcl
module "openai" {
  source = "../openai"

  resource_group_name = "rg-platform-prod"
  location            = "canadacentral"
  name                = "oai-platform-prod-cc-001"

  enable_diagnostics             = true
  log_analytics_workspace_id     = module.log_analytics.id
  log_analytics_destination_type = "Dedicated"
  diagnostic_log_categories      = ["AllLogs"]

  app_admin_group = ["11111111-1111-1111-1111-111111111111"]
  app_user_group  = ["22222222-2222-2222-2222-222222222222"]

  role_assignments = {
    auditor = {
      principal_id         = "33333333-3333-3333-3333-333333333333"
      principal_type       = "Group"
      role_definition_name = "Reader"
    }
  }
}
```

## Notes

- Prefer Microsoft Entra ID authentication and keep `local_auth_enabled = false` unless a legacy client requires keys.
- Prefer private endpoint plus `network_acls.default_action = "Deny"` for production workloads.
- Use `Cognitive Services OpenAI User` for application principals that only need data-plane access.
