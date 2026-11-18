locals {
  normalized_assignments = {
    for k, v in var.assignments : k => {
      scope                = trimspace(v.scope)
      role_definition_name = try(trimspace(v.role_definition_name), "")
      role_definition_id   = try(trimspace(v.role_definition_id), "")
      principal_id         = try(trimspace(v.principal_id), "")
      principal_name       = try(trimspace(v.principal_name), "")
      principal_type       = try(trimspace(v.principal_type), "")
      condition            = try(trimspace(v.condition), "")
      condition_version    = try(trimspace(v.condition_version), "")
    }
  }

  principal_name_assignments = {
    for principal_name in toset([
      for assignment in values(local.normalized_assignments) : assignment.principal_name
      if assignment.principal_name != "" && assignment.principal_id == ""
    ]) : principal_name => principal_name
  }

  role_definition_name_assignments = {
    for assignment_key, assignment in local.normalized_assignments :
    assignment_key => {
      scope = assignment.scope
      name  = assignment.role_definition_name
    }
    if assignment.role_definition_name != "" && assignment.role_definition_id == ""
  }

  resolved_assignments = {
    for k, assignment in local.normalized_assignments : k => {
      scope                = assignment.scope
      role_definition_name = assignment.role_definition_name
      role_definition_id   = assignment.role_definition_id != "" ? assignment.role_definition_id : data.azurerm_role_definition.this[k].id
      principal_id         = assignment.principal_id != "" ? assignment.principal_id : data.azuread_group.this[assignment.principal_name].object_id
      principal_name       = assignment.principal_name
      principal_type       = assignment.principal_type
      condition            = assignment.condition
      condition_version    = assignment.condition_version
    }
  }

  role_assignment_names = {
    for k, assignment in local.resolved_assignments : k => uuidv5("url", join("|", [
      lower(assignment.scope),
      "id",
      lower(assignment.role_definition_id),
      lower(assignment.principal_id),
      lower(assignment.principal_type),
      assignment.condition,
      assignment.condition_version
    ]))
  }
}
