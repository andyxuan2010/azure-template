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

module "cosmos" {
  source = "../.."

  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.primary_location
  inherit_resource_group_tags   = false
  inherited_resource_group_tags = {}

  public_network_access_enabled    = false
  local_authentication_disabled    = true
  automatic_failover_enabled       = true
  multiple_write_locations_enabled = false
  total_throughput_limit           = 10000

  geo_locations = [
    {
      location          = var.primary_location
      failover_priority = 0
      zone_redundant    = true
    },
    {
      location          = var.secondary_location
      failover_priority = 1
      zone_redundant    = true
    }
  ]

  consistency_policy = {
    consistency_level = "Session"
  }

  backup = {
    type = "Continuous"
    tier = "Continuous30Days"
  }

  sql_databases = {
    application = {
      autoscale_max_ru = 4000
    }
  }

  sql_containers = {
    orders = {
      database_name       = "application"
      partition_key_paths = ["/tenantId"]
      unique_keys = [{
        paths = ["/tenantId", "/orderNumber"]
      }]
      indexing_policy = {
        included_paths = [{ path = "/*" }]
        excluded_paths = [{ path = "/largePayload/?" }]
      }
    }
  }

  enable_private_endpoint    = true
  private_endpoint_subnet_id = var.private_endpoint_subnet_id
  private_dns_zone_ids       = [var.private_dns_zone_id]

  enable_diagnostics         = true
  log_analytics_workspace_id = var.log_analytics_workspace_id

  role_assignments = var.operator_principal_id == null ? {} : {
    operator = {
      principal_id         = var.operator_principal_id
      principal_type       = "Group"
      role_definition_name = "Cosmos DB Account Reader Role"
      description          = "Read-only control-plane access for platform operators."
    }
  }

  tags = {
    Environment = "prod"
    Criticality = "High"
    DataClass   = "Confidential"
    ManagedBy   = "Terraform"
  }
}
