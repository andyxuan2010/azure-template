# Copyright (c) CCOE-Azure.
# SPDX-License-Identifier: Proprietary
#
# Module: databricks
# Description: Deploys Azure Databricks workspaces for analytics, data engineering, and machine learning workloads.
#              The module supports workspace SKU and network configuration, managed resource group behavior, private endpoint patterns, diagnostics, access connector or identity integration, role assignments, and resource group tag inheritance for governance alignment.
# Owner: Cloud Center of Excellence (CCOE)
# Maintainer: Andy Xuan@CCOE
# Repository: CCOE-Azure/azure-template
#
# Created: 2026-05-20
# Modified: 2026-07-08
# Version: 1.3.0
#
# Change History:
# - 2026-05-20 v1.0.0: Established reusable databricks module baseline for the CCOE Azure IaC template library.
# - 2026-07-08 v1.0.0: Added standardized module metadata header with ownership, maintainer, license, dates, version, and change history.
#
# This Terraform module is maintained as part of the CCOE Azure IaC template library.
# Use, modification, and distribution are governed by the repository license and organizational policy.

data "azurerm_resource_group" "rg" {
  count = local.resource_group_lookup_required ? 1 : 0

  name = local.resource_group_name
}

data "azurerm_subnet" "private_endpoint" {
  count = local.create_private_endpoints && trimspace(var.private_endpoint_subnet_id) == "" ? 1 : 0

  name                 = var.private_endpoint_subnet_name
  virtual_network_name = var.private_endpoint_vnet_name
  resource_group_name  = var.private_endpoint_network_resource_group_name
}

data "azurerm_private_dns_zone" "this" {
  for_each = local.private_dns_zone_names_effective

  name                = each.value
  resource_group_name = var.private_dns_zone_resource_group_name
}

data "azuread_group" "app_admin" {
  for_each = local.app_admin_group_names

  display_name = each.value
}

data "azuread_group" "app_user" {
  for_each = local.app_user_group_names

  display_name = each.value
}

resource "random_string" "random" {
  count       = trimspace(var.name) == "" && var.use_random_suffix ? 1 : 0
  length      = 6
  special     = false
  upper       = false
  min_numeric = 2
}

resource "azurerm_databricks_access_connector" "this" {
  count = var.create_access_connector ? 1 : 0

  name                = local.access_connector_name
  resource_group_name = local.resource_group_name
  location            = local.location
  tags                = local.merged_tags

  dynamic "identity" {
    for_each = local.access_connector_identity_type != "" ? [1] : []

    content {
      type         = local.access_connector_identity_type
      identity_ids = local.access_connector_identity_ids
    }
  }

  dynamic "timeouts" {
    for_each = var.access_connector_timeouts == null ? [] : [var.access_connector_timeouts]

    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}

resource "azurerm_databricks_workspace" "this" {
  name                                                = local.workspace_name
  resource_group_name                                 = local.resource_group_name
  location                                            = local.location
  sku                                                 = lower(var.sku)
  managed_resource_group_name                         = trimspace(var.managed_resource_group_name) != "" ? var.managed_resource_group_name : null
  public_network_access_enabled                       = var.public_network_access_enabled
  network_security_group_rules_required               = var.network_security_group_rules_required
  customer_managed_key_enabled                        = var.customer_managed_key_enabled
  infrastructure_encryption_enabled                   = var.infrastructure_encryption_enabled
  default_storage_firewall_enabled                    = local.default_storage_firewall_enabled_value
  access_connector_id                                 = local.access_connector_id_effective != "" ? local.access_connector_id_effective : null
  load_balancer_backend_address_pool_id               = trimspace(var.load_balancer_backend_address_pool_id) != "" ? var.load_balancer_backend_address_pool_id : null
  managed_disk_cmk_key_vault_id                       = trimspace(var.managed_disk_cmk_key_vault_id) != "" ? var.managed_disk_cmk_key_vault_id : null
  managed_disk_cmk_key_vault_key_id                   = trimspace(var.managed_disk_cmk_key_vault_key_id) != "" ? var.managed_disk_cmk_key_vault_key_id : null
  managed_disk_cmk_rotation_to_latest_version_enabled = trimspace(var.managed_disk_cmk_key_vault_key_id) != "" ? var.managed_disk_cmk_rotation_to_latest_version_enabled : null
  managed_services_cmk_key_vault_id                   = trimspace(var.managed_services_cmk_key_vault_id) != "" ? var.managed_services_cmk_key_vault_id : null
  managed_services_cmk_key_vault_key_id               = trimspace(var.managed_services_cmk_key_vault_key_id) != "" ? var.managed_services_cmk_key_vault_key_id : null
  tags                                                = local.merged_tags

  dynamic "custom_parameters" {
    for_each = local.enable_custom_parameters ? [var.custom_parameters] : []

    content {
      machine_learning_workspace_id                        = try(trimspace(custom_parameters.value.machine_learning_workspace_id), "") != "" ? custom_parameters.value.machine_learning_workspace_id : null
      nat_gateway_name                                     = try(trimspace(custom_parameters.value.nat_gateway_name), "") != "" ? custom_parameters.value.nat_gateway_name : null
      no_public_ip                                         = try(custom_parameters.value.no_public_ip, null)
      private_subnet_name                                  = try(trimspace(custom_parameters.value.private_subnet_name), "") != "" ? custom_parameters.value.private_subnet_name : null
      private_subnet_network_security_group_association_id = try(trimspace(custom_parameters.value.private_subnet_network_security_group_association_id), "") != "" ? custom_parameters.value.private_subnet_network_security_group_association_id : null
      public_ip_name                                       = try(trimspace(custom_parameters.value.public_ip_name), "") != "" ? custom_parameters.value.public_ip_name : null
      public_subnet_name                                   = try(trimspace(custom_parameters.value.public_subnet_name), "") != "" ? custom_parameters.value.public_subnet_name : null
      public_subnet_network_security_group_association_id  = try(trimspace(custom_parameters.value.public_subnet_network_security_group_association_id), "") != "" ? custom_parameters.value.public_subnet_network_security_group_association_id : null
      storage_account_name                                 = try(trimspace(custom_parameters.value.storage_account_name), "") != "" ? custom_parameters.value.storage_account_name : null
      storage_account_sku_name                             = try(trimspace(custom_parameters.value.storage_account_sku_name), "") != "" ? custom_parameters.value.storage_account_sku_name : null
      virtual_network_id                                   = try(trimspace(custom_parameters.value.virtual_network_id), "") != "" ? custom_parameters.value.virtual_network_id : null
      vnet_address_prefix                                  = try(trimspace(custom_parameters.value.vnet_address_prefix), "") != "" ? custom_parameters.value.vnet_address_prefix : null
    }
  }

  dynamic "enhanced_security_compliance" {
    for_each = local.enable_enhanced_security ? [var.enhanced_security_compliance] : []

    content {
      automatic_cluster_update_enabled      = try(enhanced_security_compliance.value.automatic_cluster_update_enabled, null)
      compliance_security_profile_enabled   = try(enhanced_security_compliance.value.compliance_security_profile_enabled, null)
      compliance_security_profile_standards = try(enhanced_security_compliance.value.compliance_security_profile_standards, null)
      enhanced_security_monitoring_enabled  = try(enhanced_security_compliance.value.enhanced_security_monitoring_enabled, null)
    }
  }

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  lifecycle {
    precondition {
      condition     = !var.customer_managed_key_enabled || lower(var.sku) == "premium"
      error_message = "customer_managed_key_enabled requires sku = premium."
    }

    precondition {
      condition     = !var.infrastructure_encryption_enabled || lower(var.sku) == "premium"
      error_message = "infrastructure_encryption_enabled requires sku = premium."
    }

    precondition {
      condition     = var.enhanced_security_compliance == null || lower(var.sku) == "premium"
      error_message = "enhanced_security_compliance requires sku = premium."
    }
  }
}

resource "azurerm_databricks_workspace_root_dbfs_customer_managed_key" "this" {
  count = var.root_dbfs_customer_managed_key == null ? 0 : 1

  workspace_id     = azurerm_databricks_workspace.this.id
  key_vault_key_id = var.root_dbfs_customer_managed_key.key_vault_key_id
  key_vault_id     = try(var.root_dbfs_customer_managed_key.key_vault_id, null)

  dynamic "timeouts" {
    for_each = try(var.root_dbfs_customer_managed_key.timeouts, null) == null ? [] : [var.root_dbfs_customer_managed_key.timeouts]

    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}

resource "azurerm_role_assignment" "app_admin_group" {
  for_each = local.app_admin_group_principal_ids

  scope                = azurerm_databricks_workspace.this.id
  role_definition_name = "Contributor"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "app_admin_group_storage_account_contributor" {
  for_each = local.assign_managed_storage_rbac ? local.app_admin_group_principal_ids : {}

  scope                = local.custom_storage_account_id
  role_definition_name = "Contributor"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "app_admin_group_storage_account_blob_data_contributor" {
  for_each = local.assign_managed_storage_rbac ? local.app_admin_group_principal_ids : {}

  scope                = local.custom_storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "app_user_group" {
  for_each = local.app_user_group_principal_ids

  scope                = azurerm_databricks_workspace.this.id
  role_definition_name = "Reader"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "app_user_group_storage_account_reader" {
  for_each = local.assign_managed_storage_rbac ? local.app_user_group_principal_ids : {}

  scope                = local.custom_storage_account_id
  role_definition_name = "Reader"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "app_user_group_storage_account_blob_data_reader" {
  for_each = local.assign_managed_storage_rbac ? local.app_user_group_principal_ids : {}

  scope                = local.custom_storage_account_id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  scope                                  = azurerm_databricks_workspace.this.id
  principal_id                           = each.value.principal_id
  role_definition_id                     = try(each.value.role_definition_id, null)
  role_definition_name                   = try(each.value.role_definition_name, null)
  principal_type                         = try(each.value.principal_type, null)
  description                            = try(each.value.description, null)
  name                                   = try(each.value.name, null)
  condition                              = try(each.value.condition, null)
  condition_version                      = try(each.value.condition_version, null)
  delegated_managed_identity_resource_id = try(each.value.delegated_managed_identity_resource_id, null)
  skip_service_principal_aad_check       = try(each.value.skip_service_principal_aad_check, false)
}

resource "azurerm_role_assignment" "access_connector" {
  for_each = var.create_access_connector ? var.access_connector_role_assignments : {}

  scope                                  = each.value.scope
  principal_id                           = azurerm_databricks_access_connector.this[0].identity[0].principal_id
  role_definition_id                     = try(each.value.role_definition_id, null)
  role_definition_name                   = try(each.value.role_definition_name, null)
  principal_type                         = try(each.value.principal_type, "ServicePrincipal")
  description                            = try(each.value.description, null)
  name                                   = try(each.value.name, null)
  condition                              = try(each.value.condition, null)
  condition_version                      = try(each.value.condition_version, null)
  delegated_managed_identity_resource_id = try(each.value.delegated_managed_identity_resource_id, null)
  skip_service_principal_aad_check       = try(each.value.skip_service_principal_aad_check, false)
}

resource "azurerm_private_endpoint" "this" {
  for_each = local.create_private_endpoints ? local.private_endpoint_subresources : toset([])

  name                          = "${var.private_endpoint_name_prefix}-${azurerm_databricks_workspace.this.name}-${each.key}"
  location                      = local.location
  resource_group_name           = local.resource_group_name
  subnet_id                     = local.private_endpoint_subnet_id_resolved
  custom_network_interface_name = trimspace(var.private_endpoint_network_interface_name) != "" ? "${var.private_endpoint_network_interface_name}-${each.key}" : null

  private_service_connection {
    name                           = "${var.private_service_connection_name_prefix}-${azurerm_databricks_workspace.this.name}-${each.key}"
    private_connection_resource_id = azurerm_databricks_workspace.this.id
    subresource_names              = [each.key]
    is_manual_connection           = var.private_endpoint_manual_connection_enabled
    request_message                = var.private_endpoint_manual_connection_enabled && trimspace(var.private_endpoint_request_message) != "" ? var.private_endpoint_request_message : null
  }

  dynamic "private_dns_zone_group" {
    for_each = length(local.private_dns_zone_ids) > 0 ? [1] : []

    content {
      name                 = "default"
      private_dns_zone_ids = local.private_dns_zone_ids
    }
  }

  tags = local.merged_tags
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  count = local.diagnostics_enabled ? 1 : 0

  name                           = local.diagnostic_setting_name
  target_resource_id             = azurerm_databricks_workspace.this.id
  log_analytics_workspace_id     = trimspace(var.log_analytics_workspace_id) != "" ? var.log_analytics_workspace_id : null
  log_analytics_destination_type = trimspace(var.log_analytics_workspace_id) != "" ? var.log_analytics_destination_type : null
  storage_account_id             = try(trimspace(var.diagnostic_storage_account_id), "") != "" ? var.diagnostic_storage_account_id : null
  eventhub_authorization_rule_id = try(trimspace(var.diagnostic_eventhub_authorization_rule_id), "") != "" ? var.diagnostic_eventhub_authorization_rule_id : null
  eventhub_name                  = try(trimspace(var.diagnostic_eventhub_name), "") != "" ? var.diagnostic_eventhub_name : null

  dynamic "enabled_log" {
    for_each = local.diagnostic_log_categories_effective

    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_log" {
    for_each = local.diagnostic_log_category_groups_effective

    content {
      category_group = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = toset(var.diagnostic_metric_categories)

    content {
      category = enabled_metric.value
    }
  }
}
