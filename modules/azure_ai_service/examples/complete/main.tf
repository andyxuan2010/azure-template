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

module "ai_services" {
  source = "../.."

  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  kind                          = "AIServices"
  sku_name                      = "S0"
  inherit_resource_group_tags   = false
  inherited_resource_group_tags = {}

  public_network_access_enabled   = false
  local_auth_enabled              = false
  system_managed_identity_enabled = true
  project_management_enabled      = true

  enable_private_endpoint    = true
  private_endpoint_subnet_id = var.private_endpoint_subnet_id
  private_dns_zone_ids       = [var.private_dns_zone_id]

  enable_diagnostics         = true
  log_analytics_workspace_id = var.log_analytics_workspace_id
  diagnostic_log_category_groups = [
    "audit"
  ]

  rai_policies = {
    production = {
      name             = "rai-production"
      base_policy_name = "Microsoft.Default"
      mode             = "Blocking"
      content_filters = [
        {
          name               = "Hate"
          filter_enabled     = true
          block_enabled      = true
          severity_threshold = "Medium"
          source             = "Prompt"
        },
        {
          name               = "Hate"
          filter_enabled     = true
          block_enabled      = true
          severity_threshold = "Medium"
          source             = "Completion"
        }
      ]
      tags = {
        Policy = "Production"
      }
    }
  }

  deployments = {
    chat = {
      name                   = var.deployment_name
      rai_policy_name        = "rai-production"
      version_upgrade_option = var.version_upgrade_option
      model = {
        format  = "OpenAI"
        name    = var.model_name
        version = var.model_version
      }
      sku = {
        name     = var.deployment_sku_name
        capacity = var.deployment_capacity
      }
    }
  }

  role_assignments = var.workload_principal_id == null ? {} : {
    workload = {
      principal_id         = var.workload_principal_id
      principal_type       = "ServicePrincipal"
      role_definition_name = "Cognitive Services OpenAI User"
      description          = "Data-plane access for the application workload."
    }
  }

  tags = {
    Environment = "prod"
    DataClass   = "Internal"
    ManagedBy   = "Terraform"
  }
}
