resource "azurerm_data_factory_managed_private_endpoint" "this" {
  for_each = local.endpoint

  name               = each.key
  data_factory_id    = azurerm_data_factory.this.id
  target_resource_id = each.value.target_resource_id
  subresource_name   = each.value.subresource_name
}
