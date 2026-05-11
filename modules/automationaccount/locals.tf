locals {
  # Location Configuration
  location = var.location != "" ? var.location : data.azurerm_resource_group.rg.location

  # Tag Management
  common_tags = data.azurerm_resource_group.rg.tags

  # Merge user tags with resource group tags (user tags take precedence)
  tags = merge(
    #local.common_tags,
    var.tags,
    {
      "module" = "automationaccount"
    }
  )

  # Naming Convention Components
  application_code_raw = try(data.azurerm_resource_group.rg.tags.application_id, "app")
  application_code     = lower(join("", regexall("[a-zA-Z0-9]", local.application_code_raw)))
  location_code        = lower(join("", regexall("[a-zA-Z0-9]", replace(local.location, " ", ""))))
  naming_seed          = trim("-${local.application_code}-${local.location_code}-", "-")

  # Private endpoint subnet resolution (appservice-style):
  # 1) explicit subnet ID, else 2) lookup by subnet/vnet/resource group.
  private_endpoint_vnet_name_resolved                   = var.private_endpoint_vnet_name != null ? var.private_endpoint_vnet_name : (var.pep_vnet_name != "" ? var.pep_vnet_name : null)
  private_endpoint_network_resource_group_name_resolved = var.private_endpoint_network_resource_group_name != null ? var.private_endpoint_network_resource_group_name : (var.pep_vnet_resource_group_name != "" ? var.pep_vnet_resource_group_name : null)
  private_endpoint_subnet_name_resolved = var.private_endpoint_subnet_name != null ? var.private_endpoint_subnet_name : (
    local.private_endpoint_vnet_name_resolved != null ? (contains(var.private_endpoint_vnet_exceptions, local.private_endpoint_vnet_name_resolved) ? "PrivateEndpoint2" : "PrivateEndpoint") : null
  )
  private_endpoint_subnet_id_resolved = var.private_endpoint_subnet_id != "" ? var.private_endpoint_subnet_id : try(data.azurerm_subnet.pep[0].id, "")
  private_endpoint_subresources = (
    var.enable_webhook_private_endpoint == null && var.enable_hrw_private_endpoint == null ? {
      legacy = var.private_endpoint_subresource_name == "DscAndHybridWorker" ? "DSCAndHybridWorker" : var.private_endpoint_subresource_name
      } : merge(
      var.enable_webhook_private_endpoint ? { webhook = "Webhook" } : {},
      var.enable_hrw_private_endpoint ? { hrw = "DSCAndHybridWorker" } : {}
    )
  )
  create_private_endpoint = length(local.private_endpoint_subresources) > 0 && (
    var.private_endpoint_subnet_id != "" ||
    (local.private_endpoint_subnet_name_resolved != null && local.private_endpoint_vnet_name_resolved != null && local.private_endpoint_network_resource_group_name_resolved != null)
  )

  # Generated Name (max 50 chars for Automation Account)
  generated_name          = "aa-${substr(local.naming_seed != "" ? local.naming_seed : "app", 0, 42)}-${try(random_string.random[0].result, "0000")}"
  automation_account_name = var.name != "" ? var.name : local.generated_name

  managed_identity_role_assignments_effective = var.system_managed_identity_enabled ? var.managed_identity_role_assignments : {}
  app_admin_group_values                      = compact(coalesce(var.app_admin_group, []))
  app_user_group_values                       = compact(coalesce(var.app_user_group, []))
  app_admin_group_object_ids                  = toset([for value in local.app_admin_group_values : value if can(regex("^[0-9a-fA-F-]{36}$", value))])
  app_admin_group_names                       = toset([for value in local.app_admin_group_values : value if !can(regex("^[0-9a-fA-F-]{36}$", value))])
  app_user_group_object_ids                   = toset([for value in local.app_user_group_values : value if can(regex("^[0-9a-fA-F-]{36}$", value))])
  app_user_group_names                        = toset([for value in local.app_user_group_values : value if !can(regex("^[0-9a-fA-F-]{36}$", value))])
}
