data "azuread_group" "this" {
  for_each = local.principal_name_assignments

  display_name = each.value
}

data "azurerm_role_definition" "this" {
  for_each = local.role_definition_name_assignments

  name  = each.value.name
  scope = each.value.scope
}

resource "azurerm_role_assignment" "this" {
  for_each = local.resolved_assignments

  name                 = local.role_assignment_names[each.key]
  scope                = each.value.scope
  role_definition_name = null
  role_definition_id   = each.value.role_definition_id
  principal_id         = each.value.principal_id
  principal_type       = each.value.principal_type != "" ? each.value.principal_type : null
  condition            = each.value.condition != "" ? each.value.condition : null
  condition_version    = each.value.condition_version != "" ? each.value.condition_version : null
}
