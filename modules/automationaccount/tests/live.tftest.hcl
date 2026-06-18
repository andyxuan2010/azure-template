provider "azurerm" {
  features {}
}

provider "azuread" {}

variables {
  resource_group_name             = "rg-ccoe-iac-cc-dev"
  location                        = "canadacentral"
  name                            = "aa-iactest-prod-001"
  app_env                         = "prod"
  public_access_enabled           = false
  local_auth_enabled              = false
  system_managed_identity_enabled = true
  app_admin_group                 = []
  app_user_group                  = []

  tags = {
    Owner = "CCOE"
    IaC   = "Terraform"
  }
}

run "plan_named_automation_account" {
  command = plan

  assert {
    condition     = output.name == var.name
    error_message = "Automation Account name output did not match input."
  }

  assert {
    condition     = output.location == var.location
    error_message = "Automation Account location output did not match input."
  }

  assert {
    condition     = output.local_authentication_enabled == false && output.public_network_access_enabled == false
    error_message = "Automation Account should disable local auth and public access by default."
  }

  assert {
    condition     = output.tags.Environment == "Production" && !contains(keys(output.tags), "ManagedBy") && !contains(keys(output.tags), "module") && !contains(keys(output.tags), "name") && !contains(keys(output.tags), "app_env")
    error_message = "Effective tags did not include the compact standardized Automation Account tags."
  }
}

run "plan_generated_name_without_random" {
  command = plan

  variables {
    resource_group_name         = "rg-ccoe-iac-cc-dev"
    location                    = "canadacentral"
    name                        = ""
    name_prefix                 = "aa"
    workload_name               = "shared"
    app_env                     = "poc"
    include_environment_in_name = true
    location_code               = "cc"
    instance                    = "001"
    use_random_suffix           = false
    app_admin_group             = []
    app_user_group              = []
  }

  assert {
    condition     = output.name == "aa-shared-poc-cc-001"
    error_message = "Generated deterministic Automation Account name did not match the expected naming convention."
  }

  assert {
    condition     = output.location_code == "cc"
    error_message = "Location code output did not use the explicit override."
  }
}

run "plan_identity_rbac_and_diagnostics" {
  command = plan

  variables {
    resource_group_name             = "rg-ccoe-iac-cc-dev"
    location                        = "canadacentral"
    name                            = "aa-iactest-prod-rbac"
    app_env                         = "prod"
    system_managed_identity_enabled = true

    managed_identity_role_assignments = {
      reader_rg = {
        scope                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ccoe-iac-cc-dev"
        role_definition_name = "Reader"
      }
    }

    app_admin_group = ["11111111-1111-1111-1111-111111111111"]
    app_user_group  = ["22222222-2222-2222-2222-222222222222"]

    role_assignments = {
      automation_operator = {
        principal_id         = "33333333-3333-3333-3333-333333333333"
        principal_type       = "Group"
        role_definition_name = "Automation Operator"
      }
    }

    enable_diagnostics             = true
    log_analytics_workspace_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ccoe-iac-cc-dev/providers/Microsoft.OperationalInsights/workspaces/log-iactest-prod-001"
    log_analytics_destination_type = "Dedicated"
    diagnostic_storage_account_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ccoe-iac-cc-dev/providers/Microsoft.Storage/storageAccounts/stiactestdiag001"
  }

  assert {
    condition     = output.identity_type == "SystemAssigned"
    error_message = "System-assigned identity should be enabled."
  }

  assert {
    condition     = output.diagnostics_enabled == true
    error_message = "Diagnostics should be enabled when destinations are configured."
  }

  assert {
    condition     = output.role_assignment_count == 4
    error_message = "Role assignment count should include managed identity, admin, user, and custom assignments."
  }
}

run "plan_private_endpoint_runbooks_schedules_and_variables" {
  command = plan

  variables {
    resource_group_name             = "rg-ccoe-iac-cc-dev"
    location                        = "canadacentral"
    name                            = "aa-iactest-prod-ops"
    app_env                         = "prod"
    system_managed_identity_enabled = true

    enable_webhook_private_endpoint = true
    enable_hrw_private_endpoint     = true
    private_endpoint_subnet_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ccoe-iac-cc-dev/providers/Microsoft.Network/virtualNetworks/vnet-iactest-prod-001/subnets/snet-private-endpoints"
    private_dns_zone_id             = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ccoe-iac-cc-dev/providers/Microsoft.Network/privateDnsZones/privatelink.azure-automation.net"

    runbooks = {
      hello = {
        name         = "rb-hello"
        runbook_type = "PowerShell72"
        log_verbose  = true
        log_progress = true
        publish_content_link = {
          uri = "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/quickstarts/microsoft.automation/automation-runbook-getvms/Runbooks/Get-AzureVMTutorial.ps1"
        }
      }
    }

    schedules = {
      daily = {
        name        = "sched-daily"
        frequency   = "Day"
        interval    = 1
        timezone    = "Etc/UTC"
        start_time  = "2030-01-01T00:00:00Z"
        description = "Daily automation schedule."
      }
    }

    job_schedules = {
      hello_daily = {
        runbook_name  = "hello"
        schedule_name = "daily"
        parameters = {
          resourcegroup = "rg-ccoe-iac-cc-dev"
        }
      }
    }

    string_variables = {
      environment = {
        name  = "Environment"
        value = "prod"
      }
    }

    bool_variables = {
      feature_flag = {
        name  = "FeatureFlag"
        value = true
      }
    }

    int_variables = {
      retry_count = {
        name  = "RetryCount"
        value = 3
      }
    }

    datetime_variables = {
      maintenance_window = {
        name  = "MaintenanceWindow"
        value = "2030-01-01T00:00:00Z"
      }
    }

    object_variables = {
      settings = {
        name  = "Settings"
        value = "{\"level\":\"info\"}"
      }
    }
  }

  assert {
    condition     = length(output.private_endpoint_names) == 2
    error_message = "Expected one private endpoint per requested Automation subresource."
  }

  assert {
    condition     = length(output.runbook_names) == 1 && length(output.schedule_names) == 1 && length(output.job_schedule_ids) == 1
    error_message = "Expected one runbook, one schedule, and one job schedule."
  }

  assert {
    condition     = length(output.automation_variable_ids.string) == 1 && length(output.automation_variable_ids.bool) == 1 && length(output.automation_variable_ids.int) == 1 && length(output.automation_variable_ids.datetime) == 1 && length(output.automation_variable_ids.object) == 1
    error_message = "Expected one Automation variable for each supported variable type."
  }
}
