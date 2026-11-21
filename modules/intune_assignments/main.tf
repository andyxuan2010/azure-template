resource "msgraph_resource_action" "this" {
  for_each = var.resources

  resource_url           = each.value.resource_url
  action                 = "assign"
  method                 = "POST"
  api_version            = var.api_version
  body                   = each.value.body
  response_export_values = { all = "@" }
}
