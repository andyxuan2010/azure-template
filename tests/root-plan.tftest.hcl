# Offline root harness test. All providers are mocked, so this needs no Azure
# authentication or backend, runs plan only, and creates no resources.
#
# It checks that the root configuration parses and plans with every module
# disabled, and that modules enabled through var.module_plan_enabled are wired
# into the root plan. Run from the repository root:
#   terraform init -backend=false
#   terraform test -filter=tests/root-plan.tftest.hcl

mock_provider "azurerm" {}

mock_provider "azurerm" {
  alias = "prod"
}

mock_provider "azurerm" {
  alias = "nonprod"
}

mock_provider "azurerm" {
  alias = "sbx"
}

mock_provider "azuread" {}
mock_provider "azapi" {}
mock_provider "msgraph" {}
mock_provider "random" {}

run "parse_only_with_all_modules_disabled" {
  command = plan

  variables {
    features = {}
  }

  assert {
    condition     = length([for name, enabled in var.module_plan_enabled : name if enabled]) == 0
    error_message = "The default harness must leave every module disabled."
  }
}

run "module_plan_enabled_accepts_a_partial_map" {
  command = plan

  variables {
    features = {}
    module_plan_enabled = {
      bastion = true
    }
  }

  assert {
    condition     = var.module_plan_enabled.bastion && !var.module_plan_enabled.nat_gateway
    error_message = "A partial module_plan_enabled map must enable only the listed modules and default the rest to false."
  }
}

run "plan_bastion_module" {
  command = plan

  variables {
    features = {}
    module_plan_enabled = {
      bastion = true
    }
  }
}

run "plan_nat_gateway_module" {
  command = plan

  variables {
    features = {}
    module_plan_enabled = {
      nat_gateway = true
    }
  }
}

run "plan_recovery_services_vault_module" {
  command = plan

  variables {
    features = {}
    module_plan_enabled = {
      recovery_services_vault = true
    }
  }
}

run "plan_frontdoor_module" {
  command = plan

  variables {
    features = {}
    module_plan_enabled = {
      frontdoor = true
    }
  }
}
