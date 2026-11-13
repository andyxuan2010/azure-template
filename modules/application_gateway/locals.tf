locals {
  location_code_map = {
    australiaeast      = "aue"
    brazilsouth        = "brs"
    canadacentral      = "cc"
    canadaeast         = "cae"
    centralindia       = "cin"
    centralus          = "cus"
    eastasia           = "ea"
    eastus             = "eus"
    eastus2            = "eus2"
    francecentral      = "frc"
    germanywestcentral = "gwc"
    japaneast          = "jpe"
    koreacentral       = "krc"
    northeurope        = "neu"
    southcentralus     = "scus"
    southeastasia      = "sea"
    uksouth            = "uks"
    ukwest             = "ukw"
    westcentralus      = "wcus"
    westeurope         = "weu"
    westus             = "wus"
    westus2            = "wus2"
    westus3            = "wus3"
  }

  location_code            = lookup(local.location_code_map, lower(trimspace(var.location)), lower(join("", regexall("[a-z0-9]", replace(var.location, " ", "")))))
  workload_code            = lower(join("", regexall("[a-z0-9-]", trimspace(var.workload))))
  generated_name           = substr("agw-${local.workload_code}-${local.location_code}-${var.app_env}-${trimspace(var.instance)}", 0, 80)
  application_gateway_name = trimspace(var.name) != "" ? trimspace(var.name) : local.generated_name

  merged_tags = merge(
    var.inherit_resource_group_tags ? coalesce(var.inherited_resource_group_tags, try(data.azurerm_resource_group.rg[0].tags, {})) : {},
    var.tags
  )

  public_ip_name                 = trimspace(var.public_ip_name) != "" ? var.public_ip_name : "${local.application_gateway_name}-pip"
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
