# Event Hub Examples

## Secure Namespace With One Event Hub

```hcl
module "eventhub" {
  source = "../eventhub"

  resource_group_name = "rg-platform-prod"
  location            = "eastus"
  workload_name       = "stream"
  app_env             = "prod"

  eventhubs = {
    telemetry = {
      partition_count   = 4
      message_retention = 3
    }
  }

  tags = {
    Owner = "Platform"
  }
}
```

## Private Endpoint And Firewall

```hcl
module "eventhub" {
  source = "../eventhub"

  resource_group_name           = "rg-platform-prod"
  location                      = "eastus"
  name                          = "evhns-stream-prod-eus-001"
  public_network_access_enabled = false

  network_rulesets = {
    default_action                 = "Deny"
    trusted_service_access_enabled = true
    virtual_network_rules = [
      {
        subnet_id = module.vnet.subnet_ids["snet-streaming"]
      }
    ]
  }

  enable_private_endpoint    = true
  private_endpoint_subnet_id = module.vnet.subnet_ids["snet-private-endpoints"]
  private_dns_zone_ids       = [module.private_dns.zone_ids["privatelink.servicebus.windows.net"]]
}
```

## Capture, Consumer Groups, And SAS Rules

```hcl
module "eventhub" {
  source = "../eventhub"

  resource_group_name          = "rg-platform-prod"
  location                     = "eastus"
  name                         = "evhns-stream-prod-eus-001"
  local_authentication_enabled = true

  authorization_rules = {
    namespace_sender = {
      send = true
    }
  }

  eventhubs = {
    telemetry = {
      partition_count   = 8
      message_retention = 7

      retention_description = {
        cleanup_policy          = "Delete"
        retention_time_in_hours = 168
      }

      capture_description = {
        enabled             = true
        encoding            = "Avro"
        interval_in_seconds = 300
        size_limit_in_bytes = 10485760
        destination = {
          archive_name_format = "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}"
          blob_container_name = "capture"
          storage_account_id  = module.storageaccount.id
        }
      }

      consumer_groups = {
        analytics = {
          user_metadata = "analytics processors"
        }
      }

      authorization_rules = {
        sender = {
          send = true
        }
      }
    }
  }
}
```

## Customer-Managed Key And Diagnostics

```hcl
module "eventhub" {
  source = "../eventhub"

  resource_group_name = "rg-platform-prod"
  location            = "eastus"
  name                = "evhns-stream-prod-eus-001"
  sku                 = "Premium"

  identity_ids = [azurerm_user_assigned_identity.eventhub.id]

  customer_managed_key = {
    key_vault_key_ids         = [azurerm_key_vault_key.eventhub.id]
    user_assigned_identity_id = azurerm_user_assigned_identity.eventhub.id
  }

  enable_diagnostics         = true
  log_analytics_workspace_id = module.loganalytics.id
  diagnostic_log_categories  = ["OperationalLogs", "RuntimeAuditLogs"]
}
```

## Schema Registry And Geo-DR Alias

```hcl
module "eventhub" {
  source = "../eventhub"

  resource_group_name = "rg-platform-prod"
  location            = "eastus"
  name                = "evhns-stream-prod-eus-001"

  schema_groups = {
    telemetry = {
      schema_compatibility = "Forward"
      schema_type          = "Avro"
    }
  }

  disaster_recovery_config = {
    name                 = "evhns-stream-prod-dr"
    partner_namespace_id = azurerm_eventhub_namespace.secondary.id
  }
}
```
