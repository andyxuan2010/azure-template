# Automation Account Examples

## Minimal Secure Account

```hcl
module "automationaccount" {
  source = "./modules/automationaccount"

  resource_group_name = "rg-example-prod"
  location            = "canadacentral"
  workload_name       = "ops"
  app_env             = "prod"
}
```

## Deterministic Naming

```hcl
module "automationaccount" {
  source = "./modules/automationaccount"

  resource_group_name         = "rg-example-prod"
  location                    = "canadacentral"
  name                        = ""
  name_prefix                 = "aa"
  workload_name               = "shared"
  app_env                     = "poc"
  include_environment_in_name = true
  location_code               = "cc"
  instance                    = "001"
  use_random_suffix           = false
}
```

## Identity, RBAC, And Diagnostics

```hcl
module "automationaccount" {
  source = "./modules/automationaccount"

  resource_group_name             = "rg-example-prod"
  location                        = "canadacentral"
  name                            = "aa-ops-prod-cc-001"
  app_env                         = "prod"
  system_managed_identity_enabled = true

  app_admin_group = ["11111111-1111-1111-1111-111111111111"]
  app_user_group  = ["22222222-2222-2222-2222-222222222222"]

  managed_identity_role_assignments = {
    reader_rg = {
      scope                = "/subscriptions/<sub>/resourceGroups/rg-example-prod"
      role_definition_name = "Reader"
    }
  }

  role_assignments = {
    operator = {
      principal_id         = "33333333-3333-3333-3333-333333333333"
      principal_type       = "Group"
      role_definition_name = "Automation Operator"
    }
  }

  enable_diagnostics             = true
  log_analytics_workspace_id     = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.OperationalInsights/workspaces/<workspace>"
  log_analytics_destination_type = "Dedicated"
  diagnostic_storage_account_id  = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Storage/storageAccounts/<account>"
}
```

## Private Endpoints

```hcl
module "automationaccount" {
  source = "./modules/automationaccount"

  resource_group_name = "rg-example-prod"
  location            = "canadacentral"
  name                = "aa-ops-prod-cc-001"

  public_access_enabled           = false
  enable_webhook_private_endpoint = true
  enable_hrw_private_endpoint     = true
  private_endpoint_subnet_id      = "/subscriptions/<sub>/resourceGroups/<network-rg>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/<subnet>"
  private_dns_zone_id             = "/subscriptions/<sub>/resourceGroups/<dns-rg>/providers/Microsoft.Network/privateDnsZones/privatelink.azure-automation.net"
}
```

## Runbooks, Schedules, And Variables

```hcl
module "automationaccount" {
  source = "./modules/automationaccount"

  resource_group_name = "rg-example-prod"
  location            = "canadacentral"
  name                = "aa-ops-prod-cc-001"

  runbooks = {
    hello = {
      name         = "rb-hello"
      runbook_type = "PowerShell72"
      log_verbose  = true
      publish_content_link = {
        uri = "https://raw.githubusercontent.com/example/org/main/runbooks/hello.ps1"
      }
    }
  }

  schedules = {
    daily = {
      name       = "sched-daily"
      frequency  = "Day"
      interval   = 1
      timezone   = "Etc/UTC"
      start_time = "2030-01-01T00:00:00Z"
    }
  }

  job_schedules = {
    hello_daily = {
      runbook_name  = "hello"
      schedule_name = "daily"
      parameters = {
        resourcegroup = "rg-example-prod"
      }
    }
  }

  string_variables = {
    environment = {
      name  = "Environment"
      value = "prod"
    }
  }

  object_variables = {
    settings = {
      name  = "Settings"
      value = jsonencode({ level = "info" })
    }
  }
}
```

## Customer-Managed Key

```hcl
module "automationaccount" {
  source = "./modules/automationaccount"

  resource_group_name = "rg-example-prod"
  location            = "canadacentral"
  name                = "aa-ops-prod-cc-001"

  identity_ids = [
    "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<identity>"
  ]

  encryption = {
    key_vault_key_id          = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.KeyVault/vaults/<vault>/keys/<key>/<version>"
    user_assigned_identity_id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<identity>"
  }
}
```

## Test Coverage

- `tests/live.tftest.hcl` validates named resources, deterministic generated names, RBAC and diagnostics, private endpoints, runbooks, schedules, job schedules, and variables.
