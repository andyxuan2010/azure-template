data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
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
  count       = var.name == "" ? 1 : 0
  length      = 8
  special     = false
  upper       = false
  min_numeric = 2
}

resource "azurerm_databricks_workspace" "this" {
  name                                                = local.workspace_name
  resource_group_name                                 = data.azurerm_resource_group.rg.name
  location                                            = local.location
  sku                                                 = lower(var.sku)
  managed_resource_group_name                         = trimspace(var.managed_resource_group_name) != "" ? var.managed_resource_group_name : null
  public_network_access_enabled                       = var.public_network_access_enabled
  network_security_group_rules_required               = var.network_security_group_rules_required
  customer_managed_key_enabled                        = var.customer_managed_key_enabled
  infrastructure_encryption_enabled                   = var.infrastructure_encryption_enabled
  default_storage_firewall_enabled                    = trimspace(var.access_connector_id) != "" ? var.default_storage_firewall_enabled : null
  access_connector_id                                 = trimspace(var.access_connector_id) != "" ? var.access_connector_id : null
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
      public_subnet_name                                   = try(trimspace(custom_parameters.value.public_subnet_name), "") != "" ? custom_parameters.value.public_subnet_name : null
      public_subnet_network_security_group_association_id  = try(trimspace(custom_parameters.value.public_subnet_network_security_group_association_id), "") != "" ? custom_parameters.value.public_subnet_network_security_group_association_id : null
      virtual_network_id                                   = try(trimspace(custom_parameters.value.virtual_network_id), "") != "" ? custom_parameters.value.virtual_network_id : null
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
}

resource "azurerm_role_assignment" "app_admin_group" {
  for_each = merge(
    { for object_id in local.app_admin_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_admin : "name:${name}" => group.object_id }
  )

  scope                = azurerm_databricks_workspace.this.id
  role_definition_name = "Contributor"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "app_user_group" {
  for_each = merge(
    { for object_id in local.app_user_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_user : "name:${name}" => group.object_id }
  )

  scope                = azurerm_databricks_workspace.this.id
  role_definition_name = "Reader"
  principal_id         = each.value
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.enable_diagnostics ? 1 : 0

  name                       = "${azurerm_databricks_workspace.this.name}-diagnostic-setting"
  target_resource_id         = azurerm_databricks_workspace.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = toset(var.diagnostic_log_categories)

    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = toset(var.diagnostic_metric_categories)

    content {
      category = enabled_metric.value
    }
  }
}
