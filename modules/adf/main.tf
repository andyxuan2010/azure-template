# Copyright (c) CCOE-Azure.
# SPDX-License-Identifier: Proprietary
#
# Module: adf
# Description: Deploys Azure Data Factory resources for enterprise data integration and orchestration workloads.
#              The module supports managed identity, optional Git integration, self-hosted integration runtime patterns, managed private endpoints, diagnostics, role assignments, private endpoint integration, and resource group tag inheritance for governance alignment.
# Owner: Cloud Center of Excellence (CCOE)
# Maintainer: Andy Xuan@CCOE
# Repository: CCOE-Azure/azure-template
#
# Created: 2026-04-17
# Modified: 2026-07-08
# Version: 1.3.0
#
# Change History:
# - 2026-04-17 v1.0.0: Established reusable adf module baseline for the CCOE Azure IaC template library.
# - 2026-07-08 v1.0.0: Added standardized module metadata header with ownership, maintainer, license, dates, version, and change history.
#
# This Terraform module is maintained as part of the CCOE Azure IaC template library.
# Use, modification, and distribution are governed by the repository license and organizational policy.

resource "azurerm_data_factory" "this" {
  name                             = local.adf_name
  location                         = local.location
  resource_group_name              = var.resource_group
  public_network_enabled           = var.public_network_enabled
  managed_virtual_network_enabled  = var.managed_virtual_network_enabled
  tags                             = local.merged_tags
  customer_managed_key_id          = var.customer_managed_key_id
  customer_managed_key_identity_id = var.customer_managed_key_identity_id
  purview_id                       = var.purview_id

  dynamic "identity" {
    for_each = var.identity_type != "None" ? [1] : []

    content {
      type         = var.identity_type
      identity_ids = contains(["UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type) ? var.identity_ids : null
    }
  }

  dynamic "global_parameter" {
    for_each = { for i in var.global_parameter : i.name => i if i.name != null }

    content {
      name  = global_parameter.value.name
      type  = global_parameter.value.type
      value = global_parameter.value.value
    }
  }

  dynamic "vsts_configuration" {
    for_each = local.use_vsts_configuration ? [var.vsts_configuration] : []

    content {
      account_name       = vsts_configuration.value.account_name
      branch_name        = vsts_configuration.value.branch_name
      project_name       = vsts_configuration.value.project_name
      publishing_enabled = try(vsts_configuration.value.publishing_enabled, true)
      repository_name    = vsts_configuration.value.repository_name
      root_folder        = vsts_configuration.value.root_folder
      tenant_id          = vsts_configuration.value.tenant_id
    }
  }

  dynamic "github_configuration" {
    for_each = local.use_github_configuration ? [var.github_configuration] : []

    content {
      account_name       = github_configuration.value.account_name
      branch_name        = github_configuration.value.branch_name
      git_url            = github_configuration.value.git_url
      publishing_enabled = try(github_configuration.value.publishing_enabled, true)
      repository_name    = github_configuration.value.repository_name
      root_folder        = github_configuration.value.root_folder
    }
  }

  lifecycle {
    ignore_changes = [
      global_parameter,
    ]
  }
}

resource "azurerm_role_assignment" "data_factory" {
  for_each = local.additional_role_assignments

  scope                = azurerm_data_factory.this.id
  role_definition_name = each.value.role
  principal_id         = each.value.object_id
}

resource "azurerm_data_factory_integration_runtime_azure" "auto_resolve" {
  count = var.create_default_azure_integration_runtime ? 1 : 0

  data_factory_id         = azurerm_data_factory.this.id
  location                = "AutoResolve"
  name                    = local.ir_name
  time_to_live_min        = var.time_to_live_min
  virtual_network_enabled = var.virtual_network_enabled
  cleanup_enabled         = var.cleanup_enabled
  compute_type            = var.compute_type
  core_count              = var.core_count
}

resource "azurerm_data_factory_integration_runtime_self_hosted" "this" {
  count = var.self_hosted_integration_runtime_enabled ? 1 : 0

  name            = local.shir_name
  data_factory_id = azurerm_data_factory.this.id
  description     = "Self Hosted Integration Runtime for ${local.adf_name}"
}

resource "azurerm_key_vault_secret" "shir_key1" {
  count = var.self_hosted_integration_runtime_enabled ? 1 : 0

  name         = var.shir_primary_authorization_key_secret_name
  value        = azurerm_data_factory_integration_runtime_self_hosted.this[count.index].primary_authorization_key
  key_vault_id = data.azurerm_key_vault.iac[0].id
  content_type = "text/plain"
  depends_on   = [azurerm_data_factory_integration_runtime_self_hosted.this]
}

resource "azurerm_key_vault_secret" "default_key" {
  count = var.self_hosted_integration_runtime_enabled ? 1 : 0

  name         = var.shir_secondary_authorization_key_secret_name
  value        = azurerm_data_factory_integration_runtime_self_hosted.this[0].primary_authorization_key
  key_vault_id = data.azurerm_key_vault.iac[0].id
  content_type = "text/plain"
  depends_on   = [azurerm_data_factory_integration_runtime_self_hosted.this]
}

resource "azurerm_role_assignment" "app_admin_group" {
  for_each = merge(
    { for object_id in local.app_admin_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_admin : "name:${name}" => group.object_id }
  )

  scope                = azurerm_data_factory.this.id
  role_definition_name = "Contributor"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "app_user_group" {
  for_each = merge(
    { for object_id in local.app_user_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_user : "name:${name}" => group.object_id }
  )

  scope                = azurerm_data_factory.this.id
  role_definition_name = "Reader"
  principal_id         = each.value
}

# this is the example to create the SHIR- Self Hosted Integration Runtime
module "shir" {
  count  = var.self_hosted_integration_runtime_enabled ? 1 : 0
  source = "../winvm"

  location    = local.location
  app_vnet    = data.azurerm_virtual_network.app[0].name
  app_snet    = data.azurerm_subnet.app[0].name
  app_vnet_rg = data.azurerm_virtual_network.app[0].resource_group_name
  app_rg      = var.app_rg
  app_env     = var.app_env
  workload    = var.workload
  app_vm      = var.app_vm

  iac_rg = data.azurerm_resource_group.iac[0].name
  iac_st = data.azurerm_storage_account.iac[0].name
  iac_kv = data.azurerm_key_vault.iac[0].name

  enable_shir                    = var.self_hosted_integration_runtime_enabled
  enable_custom_script_extension = true

  app_user_group  = var.app_user_group
  app_admin_group = var.app_admin_group
  depends_on      = [azurerm_data_factory.this, azurerm_data_factory_integration_runtime_self_hosted.this]
  tags            = local.merged_tags
  adf_id          = azurerm_data_factory.this.id
}

resource "azurerm_private_endpoint" "adf_datafactory" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "pep-${local.adf_name}"
  location            = local.location
  resource_group_name = var.resource_group
  subnet_id           = local.private_endpoint_subnet_id_final
  tags                = local.merged_tags

  private_service_connection {
    name                           = "pls-${local.adf_name}"
    private_connection_resource_id = azurerm_data_factory.this.id
    subresource_names              = ["datafactory"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = local.private_dns_zone_id_final != "" ? [1] : []

    content {
      name                 = "adf-df-zone-group"
      private_dns_zone_ids = [local.private_dns_zone_id_final]
    }
  }
}

resource "azurerm_role_assignment" "secret_user" {
  count                = local.iac_lookup_required && contains(["SystemAssigned", "SystemAssigned, UserAssigned"], var.identity_type) ? 1 : 0
  scope                = data.azurerm_key_vault.iac[0].id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_data_factory.this.identity[0].principal_id
  depends_on           = [azurerm_data_factory.this]
}
