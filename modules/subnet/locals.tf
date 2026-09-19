locals {
  subnet_network_security_group_associations = {
    for name, subnet in var.subnets : name => subnet.network_security_group_id
    if subnet.create_network_security_group_association
  }

  subnet_route_table_associations = {
    for name, subnet in var.subnets : name => subnet.route_table_id
    if subnet.create_route_table_association
  }

  entra_object_id_pattern    = "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
  app_admin_group_values     = distinct(compact([for value in coalesce(var.app_admin_group, []) : trimspace(value)]))
  app_user_group_values      = distinct(compact([for value in coalesce(var.app_user_group, []) : trimspace(value)]))
  app_admin_group_object_ids = toset([for value in local.app_admin_group_values : value if can(regex(local.entra_object_id_pattern, value))])
  app_admin_group_names      = toset([for value in local.app_admin_group_values : value if !can(regex(local.entra_object_id_pattern, value))])
  app_user_group_object_ids  = toset([for value in local.app_user_group_values : value if can(regex(local.entra_object_id_pattern, value))])
  app_user_group_names       = toset([for value in local.app_user_group_values : value if !can(regex(local.entra_object_id_pattern, value))])

  role_assignment_enabled         = length(local.app_admin_group_values) > 0 || length(local.app_user_group_values) > 0
  virtual_network_lookup_required = var.virtual_network_id == "" && local.role_assignment_enabled
  virtual_network_id              = var.virtual_network_id != "" ? var.virtual_network_id : data.azurerm_virtual_network.this[0].id
}
