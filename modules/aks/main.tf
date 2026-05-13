data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_private_dns_zone" "this" {
  count = local.private_dns_zone_lookup_required ? 1 : 0

  name                = var.private_dns_zone_name
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

resource "random_string" "name" {
  count       = var.name == "" ? 1 : 0
  length      = 4
  special     = false
  upper       = false
  min_numeric = 1
}

resource "azurerm_kubernetes_cluster" "this" {
  name                              = local.aks_name
  location                          = local.location
  resource_group_name               = data.azurerm_resource_group.rg.name
  dns_prefix                        = local.dns_prefix
  kubernetes_version                = var.kubernetes_version
  sku_tier                          = var.sku_tier
  automatic_upgrade_channel         = var.automatic_upgrade_channel
  private_cluster_enabled           = var.private_cluster_enabled
  private_dns_zone_id               = local.private_dns_zone_id_resolved
  role_based_access_control_enabled = var.role_based_access_control_enabled
  local_account_disabled            = var.local_account_disabled
  oidc_issuer_enabled               = var.oidc_issuer_enabled
  workload_identity_enabled         = var.workload_identity_enabled

  default_node_pool {
    name                 = var.default_node_pool.name
    vm_size              = var.default_node_pool.vm_size
    node_count           = var.default_node_pool.enable_auto_scaling ? null : var.default_node_pool.node_count
    auto_scaling_enabled = var.default_node_pool.enable_auto_scaling
    min_count            = var.default_node_pool.enable_auto_scaling ? var.default_node_pool.min_count : null
    max_count            = var.default_node_pool.enable_auto_scaling ? var.default_node_pool.max_count : null
    zones                = length(var.default_node_pool.zones) > 0 ? var.default_node_pool.zones : null
    os_disk_size_gb      = var.default_node_pool.os_disk_size_gb
    max_pods             = try(var.default_node_pool.max_pods, null)
    vnet_subnet_id = (
      try(var.default_node_pool.vnet_subnet_id, null) == null ||
      trimspace(try(var.default_node_pool.vnet_subnet_id, "")) == ""
    ) ? null : var.default_node_pool.vnet_subnet_id
    only_critical_addons_enabled = var.default_node_pool.only_critical_addons_enabled
    orchestrator_version         = try(var.default_node_pool.orchestrator_version, null)
    os_sku                       = var.default_node_pool.os_sku
    type                         = var.default_node_pool.type
  }

  identity {
    type = "SystemAssigned"
  }

  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.role_based_access_control_enabled ? [1] : []

    content {
      azure_rbac_enabled     = var.azure_rbac_enabled
      admin_group_object_ids = local.admin_group_object_ids
      tenant_id              = data.azurerm_client_config.current.tenant_id
    }
  }

  network_profile {
    network_plugin      = var.network_profile.network_plugin
    network_plugin_mode = try(var.network_profile.network_plugin_mode, null)
    network_policy      = try(var.network_profile.network_policy, null)
    service_cidr        = try(var.network_profile.service_cidr, null)
    dns_service_ip      = try(var.network_profile.dns_service_ip, null)
    load_balancer_sku   = lower(var.network_profile.load_balancer_sku)
    outbound_type       = var.network_profile.outbound_type
  }

  tags = local.effective_tags
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.enable_diagnostics ? 1 : 0

  name                       = "${azurerm_kubernetes_cluster.this.name}-diagnostic-setting"
  target_resource_id         = azurerm_kubernetes_cluster.this.id
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

resource "azurerm_role_assignment" "app_admin_group" {
  for_each = merge(
    { for object_id in local.app_admin_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_admin : "name:${name}" => group.object_id }
  )

  scope                = azurerm_kubernetes_cluster.this.id
  role_definition_name = "Contributor"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "app_user_group" {
  for_each = merge(
    { for object_id in local.app_user_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_user : "name:${name}" => group.object_id }
  )

  scope                = azurerm_kubernetes_cluster.this.id
  role_definition_name = "Reader"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "terraform_execution_identity_cluster_access" {
  count = var.terraform_execution_aks_role != "" ? 1 : 0

  scope                = azurerm_kubernetes_cluster.this.id
  role_definition_name = var.terraform_execution_aks_role
  principal_id         = data.azurerm_client_config.current.object_id
}
