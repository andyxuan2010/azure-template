# Copyright (c) CCOE-Azure.
# SPDX-License-Identifier: Proprietary
# Module: ado_service_connection_acr
# Description: Secretless Azure DevOps Docker registry service connection.
# Owner: Cloud Center of Excellence (CCOE)
# Maintainer: Andy Xuan@CCOE
# Repository: CCOE-Azure/azure-template
# Created: 2026-11-10
# Version: 1.1.0
# Change History:
# - 2026-11-10 v1.1.0: Generate distinct credential names and reject duplicate pipeline IDs.
# - 2026-11-10 v1.0.0: Added workload federation and explicit pipeline authorization.

resource "azuredevops_serviceendpoint_azurecr" "this" {
  project_id                             = var.project_id
  service_endpoint_name                  = var.name
  description                            = var.description
  service_endpoint_authentication_scheme = "WorkloadIdentityFederation"
  resource_group                         = split("/", var.registry_id)[4]
  azurecr_name                           = split("/", var.registry_id)[8]
  azurecr_subscription_id                = split("/", var.registry_id)[2]
  azurecr_subscription_name              = var.subscription_name
  azurecr_spn_tenantid                   = var.managed_identity.tenant_id
  credentials {
    serviceprincipalid = var.managed_identity.client_id
  }
}

resource "azurerm_federated_identity_credential" "this" {
  name = local.federated_credential_name
  # Required by early AzureRM 4.x; deprecated but harmless in newer 4.x versions.
  resource_group_name = split("/", var.managed_identity.id)[4]
  parent_id           = var.managed_identity.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azuredevops_serviceendpoint_azurecr.this.workload_identity_federation_issuer
  subject             = azuredevops_serviceendpoint_azurecr.this.workload_identity_federation_subject
}

resource "azuredevops_pipeline_authorization" "this" {
  for_each = var.pipeline_ids

  project_id  = var.project_id
  resource_id = azuredevops_serviceendpoint_azurecr.this.id
  type        = "endpoint"
  pipeline_id = each.value

  # Enable pipeline use only after the trust has been provisioned.
  depends_on = [azurerm_federated_identity_credential.this]
}
