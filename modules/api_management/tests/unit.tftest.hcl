mock_provider "azurerm" {}

variables {
  name                          = "apim-platform-dev-001"
  location                      = "Canada Central"
  resource_group_name           = "rg-platform-dev"
  publisher_name                = "Contoso Platform"
  publisher_email               = "platform@example.com"
  inherit_resource_group_tags   = false
  inherited_resource_group_tags = {}
  tags = {
    Owner = "CCOE"
  }
}

run "plan_developer_service" {
  command = plan

  assert {
    condition     = azurerm_api_management.this.name == var.name && azurerm_api_management.this.sku_name == "Developer_1"
    error_message = "The API Management name or default Developer SKU was not propagated."
  }

  assert {
    condition     = azurerm_api_management.this.publisher_email == var.publisher_email && output.tags.Owner == "CCOE"
    error_message = "Publisher details or caller tags were not propagated."
  }

  assert {
    condition     = azurerm_api_management.this.virtual_network_type == "None" && azurerm_api_management.this.public_network_access_enabled
    error_message = "The API Management network defaults were not propagated."
  }
}

run "reject_vnet_mode_without_subnet" {
  command = plan

  variables {
    virtual_network_type = "Internal"
  }

  expect_failures = [
    azurerm_api_management.this,
  ]
}
