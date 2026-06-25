locals {
  merged_tags = merge(
    var.inherit_resource_group_tags ? coalesce(var.inherited_resource_group_tags, try(data.azurerm_resource_group.rg[0].tags, {})) : {},
    var.tags
  )

  public_ip_name                 = trimspace(var.public_ip_name) != "" ? var.public_ip_name : "${var.name}-pip"
  frontend_ip_configuration_name = "public"
  use_autoscale                  = var.autoscale_configuration != null
  waf_configuration_enabled      = var.waf_configuration != null
  frontend_port_names            = keys(var.frontend_ports)
  backend_address_pool_names     = keys(var.backend_address_pools)
  backend_http_settings_names    = keys(var.backend_http_settings)
  ssl_certificate_names          = keys(var.ssl_certificates)
  http_listener_names            = keys(var.http_listeners)
  request_routing_rule_names     = keys(var.request_routing_rules)
  url_path_map_names             = keys(var.url_path_maps)
  probe_names                    = keys(var.probes)

  diagnostics_enabled = trimspace(var.log_analytics_workspace_id) != "" && (
    length(var.diagnostic_setting_enabled_log_categories) > 0 ||
    length(var.diagnostic_setting_enabled_metric_categories) > 0
  )
}
