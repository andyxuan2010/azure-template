resource "azurerm_policy_definition" "this" {
  name                = var.name
  policy_type         = var.policy_type
  mode                = var.mode
  display_name        = var.display_name
  description         = try(trimspace(var.description), "") != "" ? var.description : null
  management_group_id = try(trimspace(var.management_group_id), "") != "" ? var.management_group_id : null
  policy_rule         = var.policy_rule
  parameters          = trimspace(var.parameters) != "" ? var.parameters : null
  metadata            = trimspace(var.metadata) != "" ? var.metadata : null
}

resource "azurerm_management_group_policy_assignment" "this" {
  count = var.create_assignment && local.assignment_scope_kind == "management_group" ? 1 : 0

  name                 = var.name
  display_name         = local.assignment_display_name_effective
  description          = local.assignment_description_effective
  policy_definition_id = azurerm_policy_definition.this.id
  management_group_id  = var.assignment_scope
  parameters           = trimspace(var.assignment_parameters) != "" ? var.assignment_parameters : null
  enforce              = var.enforcement_mode
  location             = var.identity_type != null ? var.location : null

  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []

    content {
      type = var.identity_type
    }
  }
}

resource "azurerm_subscription_policy_assignment" "this" {
  count = var.create_assignment && local.assignment_scope_kind == "subscription" ? 1 : 0

  name                 = var.name
  display_name         = local.assignment_display_name_effective
  description          = local.assignment_description_effective
  policy_definition_id = azurerm_policy_definition.this.id
  subscription_id      = var.assignment_scope
  parameters           = trimspace(var.assignment_parameters) != "" ? var.assignment_parameters : null
  enforce              = var.enforcement_mode
  location             = var.identity_type != null ? var.location : null

  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []

    content {
      type = var.identity_type
    }
  }
}

resource "azurerm_resource_group_policy_assignment" "this" {
  count = var.create_assignment && local.assignment_scope_kind == "resource_group" ? 1 : 0

  name                 = var.name
  display_name         = local.assignment_display_name_effective
  description          = local.assignment_description_effective
  policy_definition_id = azurerm_policy_definition.this.id
  resource_group_id    = var.assignment_scope
  parameters           = trimspace(var.assignment_parameters) != "" ? var.assignment_parameters : null
  enforce              = var.enforcement_mode
  location             = var.identity_type != null ? var.location : null

  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []

    content {
      type = var.identity_type
    }
  }
}
