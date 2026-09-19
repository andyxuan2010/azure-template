mock_provider "azurerm" {}

variables {
  name                = "swa-platform-prod-001"
  resource_group_name = "rg-platform-prod"
  location            = "canadacentral"
  inherited_resource_group_tags = {
    CostCenter = "platform"
  }
  tags = {
    Owner = "CCOE"
  }
}

run "plan_free_defaults" {
  command = plan

  assert {
    condition     = azurerm_static_web_app.this.sku_tier == "Free" && azurerm_static_web_app.this.sku_size == "Free"
    error_message = "Static Web App must default to the Free tier and size."
  }

  assert {
    condition     = azurerm_static_web_app.this.public_network_access_enabled == true && azurerm_static_web_app.this.preview_environments_enabled == true
    error_message = "Static Web App default public-network and preview settings regressed."
  }

  assert {
    condition     = output.tags.CostCenter == "platform" && output.tags.Owner == "CCOE"
    error_message = "Inherited and caller tags were not merged."
  }
}

run "plan_identity_and_settings" {
  command = plan

  variables {
    identity_type = "SystemAssigned"
    app_settings = {
      APP_ENV = "dev"
    }
    preview_environments_enabled = false
  }

  assert {
    condition     = azurerm_static_web_app.this.identity[0].type == "SystemAssigned"
    error_message = "System-assigned identity was not configured."
  }

  assert {
    condition     = azurerm_static_web_app.this.app_settings.APP_ENV == "dev" && azurerm_static_web_app.this.preview_environments_enabled == false
    error_message = "Application settings or preview-environment override was not passed through."
  }
}
