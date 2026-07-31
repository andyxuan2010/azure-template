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

module "databricks" {
  source = "../.."

  name                                  = var.name
  resource_group_name                   = var.resource_group_name
  location                              = var.location
  sku                                   = "premium"
  public_network_access_enabled         = false
  network_security_group_rules_required = "NoAzureDatabricksRules"
  inherit_resource_group_tags           = false
  inherited_resource_group_tags         = {}

  custom_parameters = {
    virtual_network_id                                   = var.virtual_network_id
    public_subnet_name                                   = var.public_subnet_name
    private_subnet_name                                  = var.private_subnet_name
    public_subnet_network_security_group_association_id  = var.public_subnet_nsg_association_id
    private_subnet_network_security_group_association_id = var.private_subnet_nsg_association_id
    no_public_ip                                         = true
    storage_account_sku_name                             = "Standard_ZRS"
  }

  enhanced_security_compliance = {
    automatic_cluster_update_enabled     = true
    enhanced_security_monitoring_enabled = true
  }

  private_endpoint_subresource_names = ["databricks_ui_api"]
  private_endpoint_subnet_id         = var.private_endpoint_subnet_id
  private_dns_zone_ids               = [var.private_dns_zone_id]

  enable_diagnostics         = true
  log_analytics_workspace_id = var.log_analytics_workspace_id

  role_assignments = var.platform_operator_principal_id == null ? {} : {
    platform_operator = {
      principal_id         = var.platform_operator_principal_id
      principal_type       = "Group"
      role_definition_name = "Reader"
      description          = "Read-only Azure management-plane access."
    }
  }

  tags = {
    Environment = "prod"
    DataClass   = "Confidential"
    ManagedBy   = "Terraform"
  }
}
