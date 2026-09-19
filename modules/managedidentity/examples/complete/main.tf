terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "identity" {
  source = "../.."

  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  inherit_resource_group_tags   = false
  inherited_resource_group_tags = {}

  federated_identity_credentials = {
    aks_service_account = {
      audience = ["api://AzureADTokenExchange"]
      issuer   = var.aks_oidc_issuer_url
      subject  = "system:serviceaccount:${var.kubernetes_namespace}:${var.kubernetes_service_account_name}"
    }
  }

  role_assignments = {
    workload_access = {
      scope                = var.role_assignment_scope
      role_definition_name = var.role_definition_name
    }
  }

  tags = {
    Environment = "prod"
    Owner       = "Application Team"
  }
}
