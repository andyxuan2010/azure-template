mock_provider "azurerm" {}

variables {
  name                       = "func-orders-flex-prod"
  resource_group_name        = "rg-functions-prod"
  location                   = "canadacentral"
  service_plan_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-functions-prod/providers/Microsoft.Web/serverFarms/asp-functions-flex-prod"
  runtime_name               = "python"
  runtime_version            = "3.11"
  storage_container_endpoint = "https://stfunctionsprod.blob.core.windows.net/function-packages"
  storage_access_key         = "ZmFrZS1zdG9yYWdlLWtleQ=="
  inherited_resource_group_tags = {
    CostCenter = "platform"
  }
  tags = {
    Owner = "CCOE"
  }
}

run "plan_flex_secure_defaults" {
  command = plan

  assert {
    condition     = output.name == "func-orders-flex-prod"
    error_message = "The explicit Flex Function App name was not used."
  }

  assert {
    condition = (
      output.runtime_name == "python" &&
      output.runtime_version == "3.11" &&
      output.storage_authentication_type == "StorageAccountConnectionString" &&
      output.public_network_access_enabled == false
    )
    error_message = "Flex runtime, storage authentication, or secure network defaults regressed."
  }

  assert {
    condition     = output.tags.CostCenter == "platform" && output.tags.Owner == "CCOE"
    error_message = "Inherited and caller tags were not merged."
  }
}

run "plan_generated_name_scaling_and_identity" {
  command = plan

  variables {
    name                             = ""
    workload_name                    = "orders"
    app_env                          = "dev"
    location_code                    = "cc"
    instance                         = "002"
    identity_type                    = "SystemAssigned"
    maximum_instance_count           = 25
    instance_memory_in_mb            = 4096
    http_concurrency                 = 16
    runtime_scale_monitoring_enabled = true
    always_ready = {
      "orders-http" = 1
    }
  }

  assert {
    condition     = output.name == "func-orders-cc-dev-002"
    error_message = "Generated Flex Function App name did not match the naming convention."
  }

  assert {
    condition = (
      azurerm_function_app_flex_consumption.this.identity[0].type == "SystemAssigned" &&
      azurerm_function_app_flex_consumption.this.instance_memory_in_mb == 4096 &&
      azurerm_function_app_flex_consumption.this.maximum_instance_count == 25
    )
    error_message = "Flex identity or scaling settings were not configured."
  }
}
