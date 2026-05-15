locals {
  merged_tags = merge(
    var.tags,
    {
      module = "applicationgateway"
    }
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
  probe_names                    = keys(var.probes)
}
