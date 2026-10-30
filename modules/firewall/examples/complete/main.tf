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

module "firewall" {
  source = "../.."

  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  subnet_id                     = var.azure_firewall_subnet_id
  sku_tier                      = "Standard"
  zones                         = var.zones
  public_ip_count               = 2
  inherit_resource_group_tags   = false
  inherited_resource_group_tags = {}

  rule_collection_groups = {
    workload_egress = {
      priority = 200
      application_rule_collections = {
        approved_https = {
          priority = 210
          action   = "Allow"
          rules = {
            platform = {
              source_addresses  = var.workload_source_cidrs
              destination_fqdns = var.approved_destination_fqdns
              protocols = [{
                type = "Https"
                port = 443
              }]
            }
          }
        }
      }
      network_rule_collections = {
        azure_dns = {
          priority = 220
          action   = "Allow"
          rules = {
            dns = {
              source_addresses      = var.workload_source_cidrs
              destination_addresses = ["168.63.129.16"]
              destination_ports     = ["53"]
              protocols             = ["TCP", "UDP"]
            }
          }
        }
      }
    }
  }

  enable_diagnostics         = true
  log_analytics_workspace_id = var.log_analytics_workspace_id

  role_assignments = var.operator_principal_id == null ? {} : {
    operator = {
      principal_id         = var.operator_principal_id
      principal_type       = "Group"
      role_definition_name = "Reader"
      description          = "Read-only access for network operations."
    }
  }

  tags = {
    Environment = "prod"
    Criticality = "High"
    ManagedBy   = "Terraform"
  }
}
