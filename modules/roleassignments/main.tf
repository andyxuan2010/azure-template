data "azuread_group" "this" {
  for_each = local.principal_name_assignments

  display_name = each.value
}

data "azurerm_role_definition" "this" {
  for_each = local.role_definition_name_assignments

  name  = each.value.name
  scope = each.value.scope
}

data "azapi_resource_list" "scope_role_assignments" {
  for_each = local.assignment_scopes

  type      = "Microsoft.Authorization/roleAssignments@2022-04-01"
  parent_id = each.value

  response_export_values = {
    assignments = "value[].{principal_id: properties.principalId, role_definition_id: properties.roleDefinitionId, principal_type: properties.principalType, condition: properties.condition, condition_version: properties.conditionVersion, role_assignment_id: id}"
  }
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
