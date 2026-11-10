mock_provider "azurerm" {}

variables {
  name                        = "rsv-platform-cc-dev-001"
  resource_group_name         = "rg-backup-dev"
  location                    = "canadacentral"
  inherit_resource_group_tags = false
  tags = {
    Owner = "CCOE"
  }
}

run "plan_default_vault" {
  command = plan

  assert {
    condition     = output.name == var.name && output.sku == "Standard"
    error_message = "The Recovery Services vault name or Standard SKU was not propagated."
  }

  assert {
    condition     = output.storage_mode_type == "GeoRedundant" && output.tags.Owner == "CCOE"
    error_message = "The vault redundancy or caller tags were not propagated."
  }
}

run "plan_zone_redundant" {
  command = plan

  variables {
    storage_mode_type = "ZoneRedundant"
  }

  assert {
    condition     = output.storage_mode_type == "ZoneRedundant"
    error_message = "Zone redundant storage was not passed to the vault."
  }
}

run "reject_cross_region_restore_without_geo_redundancy" {
  command = plan

  variables {
    storage_mode_type            = "LocallyRedundant"
    cross_region_restore_enabled = true
  }

  expect_failures = [
    var.cross_region_restore_enabled,
  ]
}

run "reject_unknown_immutability_mode" {
  command = plan

  variables {
    immutability = "Permanent"
  }

  expect_failures = [
    var.immutability,
  ]
}
