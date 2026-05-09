locals {
  location = var.location

  acr_name = try(trimspace(var.name), "") != "" ? lower(trimspace(var.name)) : "acr${random_string.random[0].result}"

  tags = merge(
    var.tags,
    {
      module = "acr"
      name   = local.acr_name
    }
  )

  network_rule_ip_rules = coalesce(var.network_rule_ip_rules, [])

  app_admin_group_object_ids = [
    for value in coalesce(var.app_admin_group, []) : value
    if length(regexall("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", value)) > 0
  ]
  app_admin_group_names = {
    for value in coalesce(var.app_admin_group, []) : value => value
    if length(regexall("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", value)) == 0
  }

  app_user_group_object_ids = [
    for value in coalesce(var.app_user_group, []) : value
    if length(regexall("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", value)) > 0
  ]
  app_user_group_names = {
    for value in coalesce(var.app_user_group, []) : value => value
    if length(regexall("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", value)) == 0
  }

  create_private_endpoint          = var.enable_private_endpoint
  private_endpoint_lookup_by_name  = local.create_private_endpoint && try(trimspace(var.private_endpoint_subnet_id), "") == ""
  private_endpoint_subnet_id_final = try(trimspace(var.private_endpoint_subnet_id), "") != "" ? var.private_endpoint_subnet_id : try(data.azurerm_subnet.pep[0].id, null)
  private_dns_zone_id_resolved     = try(trimspace(var.private_dns_zone_id), "") != "" ? var.private_dns_zone_id : try(data.azurerm_private_dns_zone.this[0].id, "")
}
