data "azurerm_resource_group" "rg" {
  count = local.resource_group_lookup_required ? 1 : 0

  name = local.resource_group_name
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

resource "azurerm_public_ip" "this" {
  for_each = local.public_ip_map

  name                    = each.value
  resource_group_name     = local.resource_group_name
  location                = local.location
  allocation_method       = "Static"
  sku                     = "Standard"
  sku_tier                = var.public_ip_sku_tier
  zones                   = length(var.zones) > 0 ? var.zones : null
  domain_name_label       = try(var.public_ip_domain_name_labels[tonumber(each.key)], null)
  domain_name_label_scope = var.public_ip_domain_name_label_scope
  idle_timeout_in_minutes = var.public_ip_idle_timeout_in_minutes
  ip_version              = var.public_ip_version
  public_ip_prefix_id     = trimspace(var.public_ip_prefix_id) != "" ? var.public_ip_prefix_id : null
  reverse_fqdn            = trimspace(var.public_ip_reverse_fqdn) != "" ? var.public_ip_reverse_fqdn : null
  ip_tags                 = var.public_ip_tags
  tags                    = local.merged_tags

  dynamic "timeouts" {
    for_each = var.public_ip_timeouts == null ? [] : [var.public_ip_timeouts]

    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_public_ip" "management" {
  count = local.create_management_public_ip ? 1 : 0

  name                    = local.management_public_ip_name
  resource_group_name     = local.resource_group_name
  location                = local.location
  allocation_method       = "Static"
  sku                     = "Standard"
  sku_tier                = var.public_ip_sku_tier
  zones                   = length(var.zones) > 0 ? var.zones : null
  domain_name_label       = trimspace(var.management_public_ip_domain_name_label) != "" ? var.management_public_ip_domain_name_label : null
  domain_name_label_scope = var.public_ip_domain_name_label_scope
  idle_timeout_in_minutes = var.public_ip_idle_timeout_in_minutes
  ip_version              = var.public_ip_version
  public_ip_prefix_id     = trimspace(var.management_public_ip_prefix_id) != "" ? var.management_public_ip_prefix_id : null
  ip_tags                 = var.public_ip_tags
  tags                    = local.merged_tags

  dynamic "timeouts" {
    for_each = var.public_ip_timeouts == null ? [] : [var.public_ip_timeouts]

    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_firewall_policy" "this" {
  count = var.create_firewall_policy ? 1 : 0

  name                              = local.firewall_policy_name
  resource_group_name               = local.resource_group_name
  location                          = local.location
  sku                               = local.firewall_policy_sku
  base_policy_id                    = trimspace(var.base_policy_id) != "" ? var.base_policy_id : null
  private_ip_ranges                 = length(var.private_ip_ranges) > 0 ? var.private_ip_ranges : null
  auto_learn_private_ranges_enabled = var.auto_learn_private_ranges_enabled
  sql_redirect_allowed              = var.sql_redirect_allowed
  threat_intelligence_mode          = var.threat_intelligence_mode
  tags                              = local.merged_tags

  dynamic "dns" {
    for_each = (var.dns_proxy_enabled || length(var.dns_servers) > 0) ? [1] : []

    content {
      proxy_enabled = var.dns_proxy_enabled
      servers       = length(var.dns_servers) > 0 ? var.dns_servers : null
    }
  }

  dynamic "identity" {
    for_each = length(var.firewall_policy_identity_ids) > 0 ? [1] : []

    content {
      type         = "UserAssigned"
      identity_ids = var.firewall_policy_identity_ids
    }
  }

  dynamic "insights" {
    for_each = var.policy_insights == null ? [] : [var.policy_insights]

    content {
      enabled                            = insights.value.enabled
      default_log_analytics_workspace_id = insights.value.default_log_analytics_workspace_id
      retention_in_days                  = try(insights.value.retention_in_days, null)

      dynamic "log_analytics_workspace" {
        for_each = coalesce(try(insights.value.log_analytics_workspaces, null), [])

        content {
          id                = log_analytics_workspace.value.id
          firewall_location = log_analytics_workspace.value.firewall_location
        }
      }
    }
  }

  dynamic "intrusion_detection" {
    for_each = var.intrusion_detection == null ? [] : [var.intrusion_detection]

    content {
      mode           = try(intrusion_detection.value.mode, null)
      private_ranges = try(intrusion_detection.value.private_ranges, null)

      dynamic "signature_overrides" {
        for_each = coalesce(try(intrusion_detection.value.signature_overrides, null), [])

        content {
          id    = try(signature_overrides.value.id, null)
          state = try(signature_overrides.value.state, null)
        }
      }

      dynamic "traffic_bypass" {
        for_each = coalesce(try(intrusion_detection.value.traffic_bypass, null), [])

        content {
          name                  = traffic_bypass.value.name
          protocol              = traffic_bypass.value.protocol
          description           = try(traffic_bypass.value.description, null)
          source_addresses      = try(traffic_bypass.value.source_addresses, null)
          source_ip_groups      = try(traffic_bypass.value.source_ip_groups, null)
          destination_addresses = try(traffic_bypass.value.destination_addresses, null)
          destination_ip_groups = try(traffic_bypass.value.destination_ip_groups, null)
          destination_ports     = try(traffic_bypass.value.destination_ports, null)
        }
      }
    }
  }

  dynamic "threat_intelligence_allowlist" {
    for_each = length(var.threat_intelligence_allowlist_fqdns) + length(var.threat_intelligence_allowlist_ip_addresses) > 0 ? [1] : []

    content {
      fqdns        = length(var.threat_intelligence_allowlist_fqdns) > 0 ? var.threat_intelligence_allowlist_fqdns : null
      ip_addresses = length(var.threat_intelligence_allowlist_ip_addresses) > 0 ? var.threat_intelligence_allowlist_ip_addresses : null
    }
  }

  dynamic "tls_certificate" {
    for_each = var.tls_certificate == null ? [] : [var.tls_certificate]

    content {
      name                = tls_certificate.value.name
      key_vault_secret_id = tls_certificate.value.key_vault_secret_id
    }
  }

  dynamic "explicit_proxy" {
    for_each = var.explicit_proxy == null ? [] : [var.explicit_proxy]

    content {
      enabled         = try(explicit_proxy.value.enabled, null)
      http_port       = try(explicit_proxy.value.http_port, null)
      https_port      = try(explicit_proxy.value.https_port, null)
      enable_pac_file = try(explicit_proxy.value.enable_pac_file, null)
      pac_file_port   = try(explicit_proxy.value.pac_file_port, null)
      pac_file        = try(explicit_proxy.value.pac_file, null)
    }
  }

  dynamic "timeouts" {
    for_each = var.firewall_policy_timeouts == null ? [] : [var.firewall_policy_timeouts]

    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}

resource "azurerm_firewall" "this" {
  name                = local.firewall_name
  resource_group_name = local.resource_group_name
  location            = local.location
  sku_name            = var.sku_name
  sku_tier            = var.sku_tier
  firewall_policy_id  = local.firewall_policy_id != "" ? local.firewall_policy_id : null
  dns_servers         = !local.firewall_policy_attached && length(var.dns_servers) > 0 ? var.dns_servers : null
  dns_proxy_enabled   = !local.firewall_policy_attached ? var.dns_proxy_enabled : null
  private_ip_ranges   = !local.firewall_policy_attached && length(var.private_ip_ranges) > 0 ? var.private_ip_ranges : null
  threat_intel_mode   = !local.firewall_policy_attached ? var.threat_intelligence_mode : null
  zones               = length(var.zones) > 0 ? var.zones : null
  tags                = local.merged_tags

  dynamic "ip_configuration" {
    for_each = var.sku_name == "AZFW_VNet" ? local.firewall_ip_configurations : {}

    content {
      name                 = ip_configuration.value.name
      subnet_id            = ip_configuration.value.subnet_id
      public_ip_address_id = ip_configuration.value.public_ip_address_id
    }
  }

  dynamic "management_ip_configuration" {
    for_each = local.management_ip_configuration_set ? [1] : []

    content {
      name                 = var.management_ip_configuration_name
      subnet_id            = var.management_subnet_id
      public_ip_address_id = local.management_public_ip_id
    }
  }

  dynamic "virtual_hub" {
    for_each = var.sku_name == "AZFW_Hub" ? [1] : []

    content {
      virtual_hub_id  = var.virtual_hub_id
      public_ip_count = var.virtual_hub_public_ip_count
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
}

resource "azurerm_firewall_policy_rule_collection_group" "this" {
  for_each = local.rule_collection_groups

  name               = try(trimspace(each.value.name), "") != "" ? trimspace(each.value.name) : each.key
  firewall_policy_id = local.firewall_policy_id
  priority           = each.value.priority

  dynamic "application_rule_collection" {
    for_each = coalesce(try(each.value.application_rule_collections, null), {})

    content {
      name     = try(trimspace(application_rule_collection.value.name), "") != "" ? trimspace(application_rule_collection.value.name) : application_rule_collection.key
      priority = application_rule_collection.value.priority
      action   = application_rule_collection.value.action

      dynamic "rule" {
        for_each = application_rule_collection.value.rules

        content {
          name                  = try(trimspace(rule.value.name), "") != "" ? trimspace(rule.value.name) : rule.key
          description           = try(rule.value.description, null)
          source_addresses      = try(rule.value.source_addresses, null)
          source_ip_groups      = try(rule.value.source_ip_groups, null)
          destination_addresses = try(rule.value.destination_addresses, null)
          destination_fqdns     = try(rule.value.destination_fqdns, null)
          destination_urls      = try(rule.value.destination_urls, null)
          destination_fqdn_tags = try(rule.value.destination_fqdn_tags, null)
          terminate_tls         = try(rule.value.terminate_tls, null)
          web_categories        = try(rule.value.web_categories, null)

          dynamic "protocols" {
            for_each = rule.value.protocols

            content {
              type = protocols.value.type
              port = protocols.value.port
            }
          }

          dynamic "http_headers" {
            for_each = coalesce(try(rule.value.http_headers, null), [])

            content {
              name  = http_headers.value.name
              value = http_headers.value.value
            }
          }
        }
      }
    }
  }

  dynamic "network_rule_collection" {
    for_each = coalesce(try(each.value.network_rule_collections, null), {})

    content {
      name     = try(trimspace(network_rule_collection.value.name), "") != "" ? trimspace(network_rule_collection.value.name) : network_rule_collection.key
      priority = network_rule_collection.value.priority
      action   = network_rule_collection.value.action

      dynamic "rule" {
        for_each = network_rule_collection.value.rules

        content {
          name                  = try(trimspace(rule.value.name), "") != "" ? trimspace(rule.value.name) : rule.key
          description           = try(rule.value.description, null)
          source_addresses      = try(rule.value.source_addresses, null)
          source_ip_groups      = try(rule.value.source_ip_groups, null)
          destination_addresses = try(rule.value.destination_addresses, null)
          destination_ip_groups = try(rule.value.destination_ip_groups, null)
          destination_fqdns     = try(rule.value.destination_fqdns, null)
          destination_ports     = rule.value.destination_ports
          protocols             = rule.value.protocols
        }
      }
    }
  }

  dynamic "nat_rule_collection" {
    for_each = coalesce(try(each.value.nat_rule_collections, null), {})

    content {
      name     = try(trimspace(nat_rule_collection.value.name), "") != "" ? trimspace(nat_rule_collection.value.name) : nat_rule_collection.key
      priority = nat_rule_collection.value.priority
      action   = nat_rule_collection.value.action

      dynamic "rule" {
        for_each = nat_rule_collection.value.rules

        content {
          name                = try(trimspace(rule.value.name), "") != "" ? trimspace(rule.value.name) : rule.key
          description         = try(rule.value.description, null)
          source_addresses    = try(rule.value.source_addresses, null)
          source_ip_groups    = try(rule.value.source_ip_groups, null)
          destination_address = try(rule.value.destination_address, null)
          destination_ports   = try(rule.value.destination_ports, null)
          translated_address  = try(rule.value.translated_address, null)
          translated_fqdn     = try(rule.value.translated_fqdn, null)
          translated_port     = tonumber(rule.value.translated_port)
          protocols           = rule.value.protocols
        }
      }
    }
  }

  dynamic "timeouts" {
    for_each = try(each.value.timeouts, null) == null ? [] : [each.value.timeouts]

    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  depends_on = [azurerm_firewall_policy.this]
}

resource "azurerm_role_assignment" "app_admin_group" {
  for_each = local.app_admin_group_principal_ids

  scope                = azurerm_firewall.this.id
  role_definition_name = "Contributor"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "app_user_group" {
  for_each = local.app_user_group_principal_ids

  scope                = azurerm_firewall.this.id
  role_definition_name = "Reader"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  scope                                  = azurerm_firewall.this.id
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

resource "azurerm_monitor_diagnostic_setting" "this" {
  count = local.diagnostics_enabled ? 1 : 0

  name                           = local.diagnostic_setting_name
  target_resource_id             = azurerm_firewall.this.id
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

  dynamic "timeouts" {
    for_each = var.diagnostic_timeouts == null ? [] : [var.diagnostic_timeouts]

    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}
