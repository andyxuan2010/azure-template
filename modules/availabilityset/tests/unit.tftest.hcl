mock_provider "azurerm" {}

variables {
  name                = "avail-platform-cc-prod-001"
  resource_group_name = "rg-platform-prod"
  location            = "canadacentral"
  app_env             = "prod"
  workload_name       = "platform"
  inherited_resource_group_tags = {
    CostCenter = "platform"
  }
  tags = {
    Owner = "CCOE"
  }
}

run "plan_named_availability_set" {
  command = plan

  assert {
    condition     = output.name == var.name
    error_message = "Availability Set name output did not match input."
  }

  assert {
    condition     = output.platform_fault_domain_count == 2 && output.platform_update_domain_count == 5
    error_message = "Default fault and update domain counts were not applied."
  }

  assert {
    condition     = output.managed == true
    error_message = "Availability Set should default to managed."
  }

  assert {
    condition     = output.tags.CostCenter == "platform" && output.tags.Owner == "CCOE"
    error_message = "Inherited and caller tags were not merged."
  }
}

run "plan_generated_name_and_ppg" {
  command = plan

  variables {
    name                         = ""
    resource_group_name          = "rg-platform-dev"
    location                     = "canadacentral"
    location_code                = "cc"
    workload_name                = "app"
    app_env                      = "dev"
    instance                     = "002"
    platform_fault_domain_count  = 3
    platform_update_domain_count = 10
    proximity_placement_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-platform-dev/providers/Microsoft.Compute/proximityPlacementGroups/ppg-app-dev"
    inherited_resource_group_tags = {
      Environment = "Development"
    }
  }

  assert {
    condition     = output.name == "avail-app-cc-dev-002"
    error_message = "Generated Availability Set name did not match the naming convention."
  }

  assert {
    condition     = output.platform_fault_domain_count == 3 && output.platform_update_domain_count == 10
    error_message = "Custom domain counts were not passed through."
  }

  assert {
    condition     = output.proximity_placement_group_id == var.proximity_placement_group_id
    error_message = "Proximity placement group ID was not passed through."
  }
}
