locals {
  environment_tag_map = {
    prod    = "Production"
    dev     = "Development"
    qa      = "QA"
    test    = "Test"
    sbx     = "Sandbox"
    poc     = "POC"
    staging = "Staging"
  }

  is_windows = lower(var.kind) == "windows"
  location   = trimspace(var.location) != "" ? trimspace(var.location) : data.azurerm_resource_group.this[0].location

  https_only = true

  container_registry_use_managed_identity = coalesce(var.container_registry_use_managed_identity, var.container_registry_managed_identity_client_id != null)

  active_directory_client_id_normalized = var.active_directory_client_id == null ? "" : trimspace(var.active_directory_client_id)
  # In auto mode, preserve legacy behavior: Easy Auth turns on when a client ID is supplied.
  easy_auth_enabled = var.auth_mode == "auto" ? local.active_directory_client_id_normalized != "" : contains(["easy_auth", "both"], var.auth_mode)
  msal_enabled      = contains(["msal", "both"], var.auth_mode)
  # Keep the final Easy Auth response explicit so callers can override defaults safely.
  auth_settings_unauthenticated_action = coalesce(var.unauthenticated_action, var.allow_anonymous ? "AllowAnonymous" : "RedirectToLoginPage")

  # The following values are set explicitly to keep auth behavior deterministic.
  auth_settings_enabled                            = local.easy_auth_enabled
  auth_settings_require_authentication             = local.auth_settings_unauthenticated_action != "AllowAnonymous"
  auth_settings_default_provider                   = var.auth_default_provider
  auth_settings_excluded_paths                     = var.auth_excluded_paths
  auth_settings_token_store_enabled                = var.auth_token_store_enabled
  auth_settings_allowed_external_redirect_urls     = var.auth_allowed_external_redirect_urls
  active_directory_tenant_auth_endpoint            = coalesce(var.active_directory_tenant_auth_endpoint, "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/v2.0")
  active_directory_allowed_audiences               = var.active_directory_allowed_audiences == null ? (local.active_directory_client_id_normalized != "" ? ["api://${local.active_directory_client_id_normalized}"] : []) : var.active_directory_allowed_audiences
  active_directory_allowed_groups                  = var.active_directory_allowed_groups
  active_directory_allowed_applications            = var.active_directory_allowed_applications
  active_directory_allowed_identities              = var.active_directory_allowed_identities
  active_directory_jwt_allowed_client_applications = var.active_directory_jwt_allowed_client_applications
  active_directory_jwt_allowed_groups              = var.active_directory_jwt_allowed_groups

  # Auto assign Key Vault reference identity
  identity_ids = concat(compact([var.key_vault_reference_identity_id]), var.identity_ids)

  # If system_assigned_identity_enabled is true, value is "SystemAssigned".
  # If identity_ids is non-empty, value is "UserAssigned".
  # If system_assigned_identity_enabled is true and identity_ids is non-empty, value is "SystemAssigned, UserAssigned".
  identity_type = join(", ", compact([var.system_assigned_identity_enabled ? "SystemAssigned" : "", length(local.identity_ids) > 0 ? "UserAssigned" : ""]))

  web_app = local.is_windows ? azurerm_windows_web_app.this[0] : azurerm_linux_web_app.this[0]

  # SCM Basic Auth: explicit variable overrides webdeploy (same Azure setting)
  webdeploy_publish_basic_authentication_enabled = coalesce(var.scm_basic_auth_publishing_credentials_enabled, var.webdeploy_publish_basic_authentication_enabled)
  scm_ip_security_restrictions_use_main          = coalesce(var.scmIpSecurityRestrictionsUseMain, var.scm_use_main_ip_restriction)

  application_insights_name_resolved         = try(trimspace(var.application_insights_name), "") != "" ? trimspace(var.application_insights_name) : "appi-${var.app_name}"
  application_insights_workspace_id_resolved = trimspace(var.application_insights_workspace_id) != "" ? trimspace(var.application_insights_workspace_id) : trimspace(var.log_analytics_workspace_id)
  application_insights_default_app_settings = var.enable_application_insights ? {
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.this[0].connection_string
    APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.this[0].instrumentation_key
  } : {}
  app_settings_merged = merge(local.application_insights_default_app_settings, var.app_settings)

}

locals {
  merged_tags = merge(
    var.inherit_resource_group_tags ? try(data.azurerm_resource_group.this[0].tags, {}) : {},
    var.tags,
    {
      Environment = lookup(local.environment_tag_map, lower(trimspace(var.app_env)), upper(trimspace(var.app_env)))
      Workload    = trimspace(var.workload)
    }
  )

  diagnostic_destination_enabled = (
    trimspace(var.log_analytics_workspace_id) != "" ||
    try(trimspace(var.diagnostic_storage_account_id), "") != "" ||
    try(trimspace(var.diagnostic_eventhub_authorization_rule_id), "") != ""
  )

  diagnostics_enabled = (var.enable_diagnostics || local.diagnostic_destination_enabled) && local.diagnostic_destination_enabled && (
    length(var.diagnostic_setting_enabled_log_categories) > 0 ||
    length(var.diagnostic_setting_enabled_metric_categories) > 0
  )

  diagnostic_log_categories_requested = var.diagnostic_category_discovery_enabled ? (length(var.diagnostic_setting_enabled_log_categories) == 0 ? try(data.azurerm_monitor_diagnostic_categories.web_app[0].log_category_types, []) : var.diagnostic_setting_enabled_log_categories) : var.diagnostic_setting_enabled_log_categories
  diagnostic_log_categories = local.diagnostics_enabled ? [
    for category in local.diagnostic_log_categories_requested : category
    if !var.diagnostic_category_discovery_enabled || length(var.diagnostic_setting_enabled_log_categories) > 0 || contains(try(data.azurerm_monitor_diagnostic_categories.web_app[0].log_category_types, []), category)
  ] : []

  diagnostic_metric_categories_requested = var.diagnostic_category_discovery_enabled ? (length(var.diagnostic_setting_enabled_metric_categories) == 0 ? try(data.azurerm_monitor_diagnostic_categories.web_app[0].metrics, []) : var.diagnostic_setting_enabled_metric_categories) : var.diagnostic_setting_enabled_metric_categories
  diagnostic_metric_categories = local.diagnostics_enabled ? [
    for category in local.diagnostic_metric_categories_requested : category
    if !var.diagnostic_category_discovery_enabled || length(var.diagnostic_setting_enabled_metric_categories) > 0 || contains(try(data.azurerm_monitor_diagnostic_categories.web_app[0].metrics, []), category)
  ] : []

  production_recommendations = contains(["prod"], try(var.app_env, "")) ? [
    "Disable public network access",
    "Enable Log Analytics diagnostics",
    "Use private endpoints"
  ] : []

  # Resolved IDs for private endpoint: use variable when set, else data source lookup
  private_endpoint_subnet_id_resolved = (var.private_endpoint_subnet_id == null ? "" : trimspace(var.private_endpoint_subnet_id)) != "" ? var.private_endpoint_subnet_id : try(data.azurerm_subnet.private_endpoint[0].id, "")
  private_dns_zone_id_resolved        = (var.private_dns_zone_id == null ? "" : trimspace(var.private_dns_zone_id)) != "" ? var.private_dns_zone_id : try(data.azurerm_private_dns_zone.webapp[0].id, "")

  # VNet integration: use subnet ID variable when set, else lookup by name (data source)
  vnet_integration_subnet_id_resolved = (var.virtual_network_subnet_id == null ? "" : trimspace(var.virtual_network_subnet_id)) != "" ? var.virtual_network_subnet_id : try(data.azurerm_subnet.vnet_integration[0].id, "")

  # Deployment Center (Azure Repos) repository URL, when fully configured
  deployment_center_azure_repos_repo_url = (
    var.deployment_center_azure_repos_organization != null &&
    var.deployment_center_azure_repos_project != null &&
    var.deployment_center_azure_repos_repository != null
  ) ? "https://dev.azure.com/${var.deployment_center_azure_repos_organization}/${var.deployment_center_azure_repos_project}/_git/${var.deployment_center_azure_repos_repository}" : null

  app_admin_group_values     = compact(coalesce(var.app_admin_group, []))
  app_admin_group_object_ids = toset([for value in local.app_admin_group_values : value if length(regexall("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", value)) > 0])
  app_admin_group_names      = toset([for value in local.app_admin_group_values : value if length(regexall("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", value)) == 0])
  app_user_group_values      = compact(coalesce(var.app_user_group, []))
  app_user_group_object_ids  = toset([for value in local.app_user_group_values : value if length(regexall("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", value)) > 0])
  app_user_group_names       = toset([for value in local.app_user_group_values : value if length(regexall("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", value)) == 0])
}
