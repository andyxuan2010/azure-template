terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.0, < 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0, < 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

module "event_hubs" {
  source = "../.."

  name                            = var.name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  sku                             = "Standard"
  capacity                        = 2
  auto_inflate_enabled            = true
  maximum_throughput_units        = 8
  public_network_access_enabled   = false
  local_authentication_enabled    = false
  system_managed_identity_enabled = true
  inherit_resource_group_tags     = false
  inherited_resource_group_tags   = {}

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
        size_limit_in_bytes = 104857600
        skip_empty_archives = true
        destination = {
          archive_name_format         = "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}"
          blob_container_name         = var.capture_container_name
          storage_account_id          = var.capture_storage_account_id
          storage_authentication_type = "SystemAssigned"
        }
      }
      consumer_groups = {
        analytics = {
          user_metadata = "Analytics pipeline."
        }
        operations = {
          user_metadata = "Operational monitoring."
        }
      }
    }
  }

  schema_groups = {
    telemetry = {
      schema_compatibility = "Forward"
      schema_type          = "Avro"
    }
  }

  enable_private_endpoint    = true
  private_endpoint_subnet_id = var.private_endpoint_subnet_id
  private_dns_zone_ids       = [var.private_dns_zone_id]

  enable_diagnostics         = true
  log_analytics_workspace_id = var.log_analytics_workspace_id

  role_assignments = merge(
    var.producer_principal_id == null ? {} : {
      producer = {
        principal_id         = var.producer_principal_id
        principal_type       = "ServicePrincipal"
        role_definition_name = "Azure Event Hubs Data Sender"
      }
    },
    var.consumer_principal_id == null ? {} : {
      consumer = {
        principal_id         = var.consumer_principal_id
        principal_type       = "ServicePrincipal"
        role_definition_name = "Azure Event Hubs Data Receiver"
      }
    }
  )

  tags = {
    Environment = "prod"
    Criticality = "High"
    ManagedBy   = "Terraform"
  }
}
