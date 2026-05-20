locals {
  assignment_display_name_effective = try(trimspace(var.assignment_display_name), "") != "" ? var.assignment_display_name : var.display_name
  assignment_description_effective  = try(trimspace(var.assignment_description), "") != "" ? var.assignment_description : var.description
  assignment_scope_kind = (
    try(trimspace(var.assignment_scope), "") == "" ? null :
    can(regex("^/providers/Microsoft\\.Management/managementGroups/[^/]+$", var.assignment_scope)) ? "management_group" :
    can(regex("^/subscriptions/[0-9a-fA-F-]{36}$", var.assignment_scope)) ? "subscription" :
    can(regex("^/subscriptions/[0-9a-fA-F-]{36}/resourceGroups/[^/]+$", var.assignment_scope)) ? "resource_group" :
    "unsupported"
  )
}
