# Azure AI Service Examples

## Minimal Secure Account

```hcl
module "azure_ai_service" {
  source = "./modules/azure_ai_service"

  resource_group_name = "rg-example-prod"
  location            = "canadacentral"
  workload_name       = "ai"
  app_env             = "prod"
  sku_name            = "S0"
}
```

## Deterministic Naming

```hcl
module "azure_ai_service" {
  source = "./modules/azure_ai_service"

  resource_group_name         = "rg-example-prod"
  location                    = "canadacentral"
  name                        = ""
  name_prefix                 = "ais"
  workload_name               = "shared"
  app_env                     = "poc"
  include_environment_in_name = true
  location_code               = "cc"
  instance                    = "001"
  use_random_suffix           = false
}
```

## Private Endpoint

```hcl
module "azure_ai_service" {
  source = "./modules/azure_ai_service"

  resource_group_name = "rg-example-prod"
  location            = "canadacentral"
  name                = "ais-ai-prod-cc-001"

  public_network_access_enabled = false
  enable_private_endpoint       = true
  private_endpoint_subnet_id    = "/subscriptions/<sub>/resourceGroups/<network-rg>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/<subnet>"
  private_dns_zone_ids = [
    "/subscriptions/<sub>/resourceGroups/<dns-rg>/providers/Microsoft.Network/privateDnsZones/privatelink.cognitiveservices.azure.com"
  ]
}
```

## Identity, RBAC, Network ACLs, And Diagnostics

```hcl
module "azure_ai_service" {
  source = "./modules/azure_ai_service"

  resource_group_name             = "rg-example-prod"
  location                        = "canadacentral"
  name                            = "ais-ai-prod-cc-001"
  app_env                         = "prod"
  system_managed_identity_enabled = true

  customer_managed_key = {
    key_vault_key_id = "https://kv-example.vault.azure.net/keys/cmk/<version>"
  }

  network_acls = {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = ["203.0.113.10"]
  }

  app_admin_group = ["11111111-1111-1111-1111-111111111111"]
  app_user_group  = ["22222222-2222-2222-2222-222222222222"]

  role_assignments = {
    cognitive_services_user = {
      principal_id         = "33333333-3333-3333-3333-333333333333"
      principal_type       = "Group"
      role_definition_name = "Cognitive Services User"
    }
  }

  enable_diagnostics         = true
  log_analytics_workspace_id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.OperationalInsights/workspaces/<workspace>"
  diagnostic_storage_account_id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Storage/storageAccounts/<account>"
}
```

## AI Foundry Project And Deployment

```hcl
module "azure_ai_service" {
  source = "./modules/azure_ai_service"

  resource_group_name             = "rg-example-prod"
  location                        = "canadacentral"
  name                            = "ais-ai-prod-cc-001"
  system_managed_identity_enabled = true
  project_management_enabled      = true

  network_injection = {
    scenario  = "agent"
    subnet_id = "/subscriptions/<sub>/resourceGroups/<network-rg>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/<agent-subnet>"
  }

  rai_policies = {
    strict = {
      name             = "rai-strict"
      base_policy_name = "Microsoft.Default"
      mode             = "Blocking"
      content_filters = [
        {
          name               = "Hate"
          filter_enabled     = true
          block_enabled      = true
          severity_threshold = "High"
          source             = "Prompt"
        }
      ]
    }
  }

  deployments = {
    chat = {
      name            = "gpt-4o-mini"
      rai_policy_name = "rai-strict"
      model = {
        format  = "OpenAI"
        name    = "gpt-4o-mini"
        version = "2024-07-18"
      }
      sku = {
        name     = "GlobalStandard"
        capacity = 10
      }
    }
  }
}
```

## Test Coverage

- `tests/live.tftest.hcl` uses mock Azure providers and validates named resources, deterministic generated names, secure defaults, caller-controlled tags, identity, CMK, network ACLs, RBAC, diagnostics, private endpoint naming, network injection, RAI policies, model deployments, and invalid network input rejection.

## Notes

- `network_acls.ip_rules` supports IPv4 addresses and CIDR ranges.
- `network_injection` requires `kind = "AIServices"` and a managed identity.
- Deployments and Responsible AI policies require `kind = "AIServices"` or `kind = "OpenAI"`.
