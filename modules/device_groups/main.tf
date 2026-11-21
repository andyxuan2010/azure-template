resource "azuread_group" "this" {
  for_each         = var.groups
  display_name     = each.value.display_name
  description      = each.value.description
  security_enabled = true
  mail_enabled     = false
  types            = each.value.membership_rule == null ? [] : ["DynamicMembership"]
  dynamic "dynamic_membership" {
    for_each = each.value.membership_rule == null ? [] : [each.value.membership_rule]
    content {
      enabled = true
      rule    = dynamic_membership.value
    }
  }
}
