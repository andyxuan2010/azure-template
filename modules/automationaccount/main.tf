# Data sources
data "azurerm_resource_group" "rg" {
  count = local.resource_group_lookup_required ? 1 : 0

  name = local.resource_group_name
}

data "azurerm_subnet" "pep" {
  count = local.create_private_endpoint && trimspace(var.private_endpoint_subnet_id) == "" ? 1 : 0

  name                 = local.private_endpoint_subnet_name_resolved
  virtual_network_name = local.private_endpoint_vnet_name_resolved
  resource_group_name  = local.private_endpoint_network_resource_group_name_resolved
}

data "azurerm_private_dns_zone" "pep" {
  count = local.create_private_endpoint && trimspace(var.private_dns_zone_id) == "" && trimspace(var.private_dns_zone_name) != "" && trimspace(var.private_dns_zone_resource_group_name) != "" ? 1 : 0

  name                = trimspace(var.private_dns_zone_name)
  resource_group_name = trimspace(var.private_dns_zone_resource_group_name)
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
  length      = 4
  special     = false
  upper       = false
  min_numeric = 1
}

resource "azurerm_automation_account" "azure_automationaccount" {
  name                          = local.automation_account_name
  location                      = local.location
  resource_group_name           = local.resource_group_name
  sku_name                      = var.sku_name
  local_authentication_enabled  = var.local_auth_enabled
  public_network_access_enabled = var.public_access_enabled

  dynamic "identity" {
    for_each = local.identity_type != "" ? [1] : []

    content {
      type         = local.identity_type
      identity_ids = local.identity_ids
    }
  }

  dynamic "encryption" {
    for_each = var.encryption == null ? [] : [var.encryption]

    content {
      key_vault_key_id          = encryption.value.key_vault_key_id
      user_assigned_identity_id = try(encryption.value.user_assigned_identity_id, null)
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

  tags = local.tags

  lifecycle {
    create_before_destroy = true

    precondition {
      condition     = var.system_managed_identity_enabled || length(var.managed_identity_role_assignments) == 0
      error_message = "managed_identity_role_assignments requires system_managed_identity_enabled = true."
    }

    precondition {
      condition = var.encryption == null ? true : (
        local.identity_type != "" &&
        (
          try(trimspace(var.encryption.user_assigned_identity_id), "") == "" ||
          contains(local.identity_ids, var.encryption.user_assigned_identity_id)
        )
      )
      error_message = "encryption requires a managed identity. If user_assigned_identity_id is set, it must also be present in identity_ids."
    }
  }
}

resource "azurerm_automation_runbook" "this" {
  for_each = var.runbooks

  name                     = each.value.name
  location                 = local.location
  resource_group_name      = local.resource_group_name
  automation_account_name  = azurerm_automation_account.azure_automationaccount.name
  runbook_type             = each.value.runbook_type
  log_progress             = each.value.log_progress
  log_verbose              = each.value.log_verbose
  description              = try(each.value.description, null)
  content                  = try(each.value.content, null)
  runtime_environment_name = try(each.value.runtime_environment_name, null)
  log_activity_trace_level = try(each.value.log_activity_trace_level, null)
  tags = merge(local.tags, try(each.value.tags, {}), {
    Environment = lookup(local.environment_tag_map, lower(trimspace(var.app_env)), upper(trimspace(var.app_env)))
    Workload    = trimspace(var.workload)
  })

  dynamic "publish_content_link" {
    for_each = try(each.value.publish_content_link, null) == null ? [] : [each.value.publish_content_link]

    content {
      uri     = publish_content_link.value.uri
      version = try(publish_content_link.value.version, null)

      dynamic "hash" {
        for_each = try(publish_content_link.value.hash, null) == null ? [] : [publish_content_link.value.hash]

        content {
          algorithm = hash.value.algorithm
          value     = hash.value.value
        }
      }
    }
  }
}

resource "azurerm_automation_schedule" "this" {
  for_each = var.schedules

  name                    = each.value.name
  resource_group_name     = local.resource_group_name
  automation_account_name = azurerm_automation_account.azure_automationaccount.name
  frequency               = each.value.frequency
  description             = try(each.value.description, null)
  interval                = try(each.value.interval, null)
  start_time              = try(each.value.start_time, null)
  expiry_time             = try(each.value.expiry_time, null)
  timezone                = try(each.value.timezone, null)
  week_days               = try(each.value.week_days, null)
  month_days              = try(each.value.month_days, null)

  dynamic "monthly_occurrence" {
    for_each = try(each.value.monthly_occurrences, [])

    content {
      day        = monthly_occurrence.value.day
      occurrence = monthly_occurrence.value.occurrence
    }
  }
}

resource "azurerm_automation_job_schedule" "this" {
  for_each = var.job_schedules

  resource_group_name     = local.resource_group_name
  automation_account_name = azurerm_automation_account.azure_automationaccount.name
  runbook_name            = try(azurerm_automation_runbook.this[each.value.runbook_name].name, each.value.runbook_name)
  schedule_name           = try(azurerm_automation_schedule.this[each.value.schedule_name].name, each.value.schedule_name)
  parameters              = try(each.value.parameters, {})
  run_on                  = try(each.value.run_on, null)
}

resource "azurerm_automation_variable_string" "this" {
  for_each = var.string_variables

  name                    = each.value.name
  resource_group_name     = local.resource_group_name
  automation_account_name = azurerm_automation_account.azure_automationaccount.name
  value                   = each.value.value
  description             = try(each.value.description, null)
  encrypted               = try(each.value.encrypted, false)
}

resource "azurerm_automation_variable_bool" "this" {
  for_each = var.bool_variables

  name                    = each.value.name
  resource_group_name     = local.resource_group_name
  automation_account_name = azurerm_automation_account.azure_automationaccount.name
  value                   = each.value.value
  description             = try(each.value.description, null)
  encrypted               = try(each.value.encrypted, false)
}

resource "azurerm_automation_variable_int" "this" {
  for_each = var.int_variables

  name                    = each.value.name
  resource_group_name     = local.resource_group_name
  automation_account_name = azurerm_automation_account.azure_automationaccount.name
  value                   = each.value.value
  description             = try(each.value.description, null)
  encrypted               = try(each.value.encrypted, false)
}

resource "azurerm_automation_variable_datetime" "this" {
  for_each = var.datetime_variables

  name                    = each.value.name
  resource_group_name     = local.resource_group_name
  automation_account_name = azurerm_automation_account.azure_automationaccount.name
  value                   = each.value.value
  description             = try(each.value.description, null)
  encrypted               = try(each.value.encrypted, false)
}

resource "azurerm_automation_variable_object" "this" {
  for_each = var.object_variables

  name                    = each.value.name
  resource_group_name     = local.resource_group_name
  automation_account_name = azurerm_automation_account.azure_automationaccount.name
  value                   = each.value.value
  description             = try(each.value.description, null)
  encrypted               = try(each.value.encrypted, false)
}

resource "azurerm_role_assignment" "managed_identity" {
  for_each = local.managed_identity_role_assignments_effective

  scope                = each.value.scope
  role_definition_name = try(each.value.role_definition_name, null)
  role_definition_id   = try(each.value.role_definition_id, null)
  principal_id         = azurerm_automation_account.azure_automationaccount.identity[0].principal_id
}

resource "azurerm_role_assignment" "app_admin_group" {
  for_each = local.app_admin_group_principal_ids

  scope                = azurerm_automation_account.azure_automationaccount.id
  role_definition_name = "Contributor"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "app_user_group" {
  for_each = local.app_user_group_principal_ids

  scope                = azurerm_automation_account.azure_automationaccount.id
  role_definition_name = "Reader"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  scope                                  = azurerm_automation_account.azure_automationaccount.id
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

resource "azurerm_private_endpoint" "pep" {
  for_each = local.create_private_endpoint ? local.private_endpoint_subresources : {}

  name                = each.key == "legacy" ? "${var.private_endpoint_name_prefix}-${azurerm_automation_account.azure_automationaccount.name}" : "${var.private_endpoint_name_prefix}-${azurerm_automation_account.azure_automationaccount.name}-${each.key}"
  location            = azurerm_automation_account.azure_automationaccount.location
  resource_group_name = local.resource_group_name
  subnet_id           = local.private_endpoint_subnet_id_resolved

  private_service_connection {
    name                           = each.key == "legacy" ? "${var.private_service_connection_name_prefix}-${azurerm_automation_account.azure_automationaccount.name}" : "${var.private_service_connection_name_prefix}-${azurerm_automation_account.azure_automationaccount.name}-${each.key}"
    private_connection_resource_id = azurerm_automation_account.azure_automationaccount.id
    subresource_names              = [each.value]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = trimspace(local.private_dns_zone_id_resolved) != "" ? [1] : []

    content {
      name                 = "default"
      private_dns_zone_ids = [local.private_dns_zone_id_resolved]
    }
  }

  tags = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_monitor_diagnostic_setting" "automation_account" {
  count = local.diagnostics_enabled ? 1 : 0

  name                           = local.diagnostic_setting_name
  target_resource_id             = azurerm_automation_account.azure_automationaccount.id
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
