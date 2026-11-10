# Copyright (c) CCOE-Azure.
# SPDX-License-Identifier: Proprietary
# Module: ado_service_connection_azurerm
# Description: Secretless Azure DevOps Azure Resource Manager service connection.
# Owner: Cloud Center of Excellence (CCOE)
# Maintainer: Andy Xuan@CCOE
# Repository: CCOE-Azure/azure-template
# Created: 2026-11-10
# Version: 1.0.0
# Change History:
# - 2026-11-10 v1.0.0: Added workload federation and explicit pipeline authorization.

resource "azuredevops_serviceendpoint_azurerm" "this" {
  project_id                             = var.project_id
  service_endpoint_name                  = var.name
  description                            = var.description
  service_endpoint_authentication_scheme = "WorkloadIdentityFederation"
  azurerm_subscription_id                = var.subscription_id
  azurerm_subscription_name              = var.subscription_name
  azurerm_spn_tenantid                   = var.managed_identity.tenant_id
  credentials {
    serviceprincipalid = var.managed_identity.client_id
  }
}

resource "azurerm_federated_identity_credential" "this" {
  name = var.federated_credential_name
  # Required by early AzureRM 4.x; deprecated but harmless in newer 4.x versions.
  resource_group_name = split("/", var.managed_identity.id)[4]
  parent_id           = var.managed_identity.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azuredevops_serviceendpoint_azurerm.this.workload_identity_federation_issuer
  subject             = azuredevops_serviceendpoint_azurerm.this.workload_identity_federation_subject
}

resource "azuredevops_pipeline_authorization" "this" {
  for_each = var.pipeline_ids

  project_id  = var.project_id
  resource_id = azuredevops_serviceendpoint_azurerm.this.id
  type        = "endpoint"
  pipeline_id = each.value

  # Enable pipeline use only after the trust has been provisioned.
  depends_on = [azurerm_federated_identity_credential.this]
}
