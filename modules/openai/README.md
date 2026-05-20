# OpenAI Module

Provision an Azure OpenAI account with secure defaults, standardized naming and tags, managed identity, customer-managed keys, model deployments, network ACLs, private endpoint, RBAC, and diagnostics.

## Features

- Secure defaults: public network access disabled, local key authentication disabled, system-assigned managed identity enabled, and custom subdomain defaulting to the account name.
- Standard generated naming using `name_prefix`, `workload_name`, `app_env`, `location_code`, and optional random suffixes.
- Standard tags including `ManagedBy`, `module`, `name`, `app_env`, and environment-specific tags.
- Backward-compatible `identity` input plus preferred `system_assigned_identity_enabled` and `identity_ids` inputs.
- Customer-managed key support with identity validation.
- Azure OpenAI deployments with model version, SKU capacity, RAI policy, dynamic throttling, upgrade policy, and optional timeouts.
- Network ACLs, private endpoint with DNS zone IDs or DNS zone name lookup, static IP configuration, custom NIC name, manual approval, and private endpoint timeouts.
- Built-in admin/user role assignments using Azure OpenAI data-plane roles by default, plus generic role assignments.
- Diagnostics to Log Analytics, Storage Account archive, and Event Hub with category and category-group support.
- Mock-provider Terraform tests for fast plan coverage without creating live Azure resources.

## Basic Usage

```hcl
module "openai" {
  source = "./modules/openai"

  resource_group_name = "rg-platform-prod"
  location            = "eastus"
  workload_name       = "ai"
  app_env             = "prod"

  deployments = {
    "gpt4o-mini" = {
      model_format = "OpenAI"
      model_name   = "gpt-4o-mini"
      sku_name     = "Standard"
      sku_capacity = 10
    }
  }

  tags = {
    Owner = "Platform"
  }
}
```

## Private Account

```hcl
module "openai" {
  source = "./modules/openai"

  resource_group_name           = "rg-platform-prod"
  location                      = "eastus"
  name                          = "oai-platform-prod-eus-001"
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

## Customer-Managed Key

```hcl
module "openai" {
  source = "./modules/openai"

  resource_group_name = "rg-platform-prod"
  location            = "eastus"
  name                = "oai-platform-cmk-prod-eus-001"

  identity_ids = [azurerm_user_assigned_identity.openai.id]

  customer_managed_key = {
    key_vault_key_id   = azurerm_key_vault_key.openai.id
    identity_client_id = azurerm_user_assigned_identity.openai.client_id
  }
}
```

## Diagnostics

```hcl
module "openai" {
  source = "./modules/openai"

  resource_group_name = "rg-platform-prod"
  location            = "eastus"
  name                = "oai-platform-prod-eus-001"

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

`tests/live.tftest.hcl` uses Terraform mock providers, so it validates module behavior without creating live Azure OpenAI resources.
