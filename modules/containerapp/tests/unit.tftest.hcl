mock_provider "azurerm" {}

variables {
  name                = "ca-platform-cc-dev-001"
  resource_group_name = "rg-platform-dev"
  location            = "canadacentral"
  inherited_resource_group_tags = {
    CostCenter = "platform"
  }
  container_app_environment_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-platform-dev/providers/Microsoft.App/managedEnvironments/cae-platform-cc-dev-001"

  ingress = {
    external_enabled = true
    target_port      = 8080
  }

  tags = {
    Owner = "CCOE"
    IaC   = "Terraform"
  }
}

run "plan_container_app_with_name_override" {
  command = plan

  assert {
    condition     = output.name == var.name && output.container_app_environment_id == var.container_app_environment_id
    error_message = "Container App name override or environment ID was not propagated."
  }

  assert {
    condition     = output.tags.CostCenter == "platform" && output.tags.Owner == "CCOE" && output.identity_type == "SystemAssigned"
    error_message = "Tag inheritance or identity defaults did not match expectations."
  }
}

run "plan_generated_name" {
  command = plan

  variables {
    name          = ""
    workload      = "orders"
    app_env       = "prod"
    instance      = "002"
    location_code = ""
  }

  assert {
    condition     = output.name == "ca-orders-cc-prod-002"
    error_message = "Generated Container App name did not match the expected naming convention."
  }
}

run "plan_registry_secret_and_scale" {
  command = plan

  variables {
    secrets = [{
      name  = "acr-password"
      value = "placeholder"
    }]

    registries = [{
      server               = "contoso.azurecr.io"
      username             = "contoso"
      password_secret_name = "acr-password"
    }]

    containers = [{
      name   = "api"
      image  = "contoso.azurecr.io/api:1.0.0"
      cpu    = 0.5
      memory = "1Gi"
      env = [{
        name  = "ASPNETCORE_URLS"
        value = "http://+:8080"
      }]
    }]

    min_replicas = 1
    max_replicas = 3

    http_scale_rules = [{
      name                = "http"
      concurrent_requests = "100"
    }]
  }

  assert {
    condition     = output.name == var.name
    error_message = "Container App registry/secret/scale scenario should still plan with the configured name."
  }
}

run "reject_invalid_replica_bounds" {
  command = plan

  variables {
    min_replicas = 3
    max_replicas = 1
  }

  expect_failures = [
    check.containerapp_input_consistency,
  ]
}
