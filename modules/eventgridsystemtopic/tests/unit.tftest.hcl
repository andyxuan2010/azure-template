mock_provider "azurerm" {}

variables {
  name                = "egt-platform-prod-001"
  resource_group_name = "rg-platform-prod"
  location            = "canadacentral"
  topic_type          = "Microsoft.Storage.StorageAccounts"
  source_resource_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-platform-prod/providers/Microsoft.Storage/storageAccounts/stplatformprod001"
  inherited_resource_group_tags = {
    CostCenter = "platform"
  }
  tags = {
    Owner = "CCOE"
  }
}

run "plan_system_topic" {
  command = plan

  assert {
    condition     = azurerm_eventgrid_system_topic.this.name == "egt-platform-prod-001"
    error_message = "The explicit Event Grid System Topic name was not used."
  }

  assert {
    condition = (
      azurerm_eventgrid_system_topic.this.topic_type == "Microsoft.Storage.StorageAccounts" &&
      azurerm_eventgrid_system_topic.this.source_resource_id == var.source_resource_id
    )
    error_message = "Topic type or source resource ID was not passed through."
  }

  assert {
    condition     = output.tags.CostCenter == "platform" && output.tags.Owner == "CCOE"
    error_message = "Inherited and caller tags were not merged."
  }
}

run "plan_generated_name_and_identity" {
  command = plan

  variables {
    name          = ""
    workload_name = "orders"
    app_env       = "dev"
    instance      = "002"
    identity_type = "SystemAssigned"
    location_code = "cc"
  }

  assert {
    condition     = output.name == "egt-orders-cc-dev-002"
    error_message = "Generated Event Grid System Topic name did not match the naming convention."
  }

  assert {
    condition     = azurerm_eventgrid_system_topic.this.identity[0].type == "SystemAssigned"
    error_message = "System-assigned identity was not configured."
  }
}
