resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.enable_diagnostics ? var.app_vm_number : 0

  name                       = "${azurerm_windows_virtual_machine.this[count.index].name}-diagnostic-setting"
  target_resource_id         = azurerm_windows_virtual_machine.this[count.index].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_metric {
    category = "AllMetrics"
  }
}
