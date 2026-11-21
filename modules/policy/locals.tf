locals {
  workload_code                     = lower(join("", regexall("[a-z0-9-]", trimspace(var.workload))))
  generated_name                    = substr("pol-${local.workload_code}-${var.app_env}-${trimspace(var.instance)}", 0, 64)
  policy_name                       = trimspace(var.name) != "" ? trimspace(var.name) : local.generated_name
  policy_display_name               = trimspace(var.display_name) != "" ? trimspace(var.display_name) : local.policy_name
  assignment_display_name_effective = try(trimspace(var.assignment_display_name), "") != "" ? var.assignment_display_name : local.policy_display_name
  assignment_description_effective  = try(trimspace(var.assignment_description), "") != "" ? var.assignment_description : var.description
  assignment_scope_kind = (
    try(trimspace(var.assignment_scope), "") == "" ? null :
    can(regex("^/providers/Microsoft\\.Management/managementGroups/[^/]+$", var.assignment_scope)) ? "management_group" :
    can(regex("^/subscriptions/[0-9a-fA-F-]{36}$", var.assignment_scope)) ? "subscription" :
    can(regex("^/subscriptions/[0-9a-fA-F-]{36}/resourceGroups/[^/]+$", var.assignment_scope)) ? "resource_group" :
    "unsupported"
  )
}
