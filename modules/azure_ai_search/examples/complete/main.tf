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

module "search" {
  source = "../.."

  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  inherit_resource_group_tags   = false
  inherited_resource_group_tags = {}

  sku                             = "standard"
  replica_count                   = 2
  partition_count                 = 2
  semantic_search_sku             = "standard"
  public_network_access_enabled   = false
  local_authentication_enabled    = false
  system_managed_identity_enabled = true

  enable_private_endpoint    = true
  private_endpoint_subnet_id = var.private_endpoint_subnet_id
  private_dns_zone_ids       = [var.private_dns_zone_id]

  shared_private_link_services = {
    content_storage = {
      name               = "spl-content-storage"
      subresource_name   = "blob"
      target_resource_id = var.content_storage_account_id
      request_message    = "Approve for private Search indexer access."
    }
  }

  enable_diagnostics         = true
  log_analytics_workspace_id = var.log_analytics_workspace_id
  diagnostic_log_categories = [
    "OperationLogs"
  ]

  role_assignments = var.workload_principal_id == null ? {} : {
    query = {
      principal_id         = var.workload_principal_id
      principal_type       = "ServicePrincipal"
      role_definition_name = "Search Index Data Reader"
      description          = "Query access for the application workload."
    }
  }

  tags = {
    Environment = "prod"
    DataClass   = "Internal"
    ManagedBy   = "Terraform"
  }
}
