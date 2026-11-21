resource "msgraph_resource" "this" {
  for_each = var.resources

  url                     = "deviceManagement/importedWindowsAutopilotDeviceIdentities"
  api_version             = var.api_version
  body                    = each.value
  ignore_missing_property = true
  response_export_values  = { id = "id", display_name = "displayName" }
}
