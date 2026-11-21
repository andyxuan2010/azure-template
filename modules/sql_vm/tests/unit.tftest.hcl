mock_provider "azurerm" {}

variables {
  resource_group_name           = "rg-platform-prod"
  location                      = "canadacentral"
  inherited_resource_group_tags = {}
  subnet_id                     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-platform/subnets/snet-sql"
  admin_username                = "azureadmin"
  admin_password                = "Terraform-Test-Password-123!"
  workload_name                 = "platform"
  app_env                       = "prod"
  tags = {
    Owner = "CCOE"
  }
}

run "plan_single_sql_vm_defaults" {
  command = plan

  assert {
    condition     = length(output.names) == 1 && output.location == var.location
    error_message = "Default SQL VM count and location were not planned correctly."
  }

  assert {
    condition     = length(output.sql_virtual_machine_ids) == 1
    error_message = "SQL IaaS registration should be enabled by default."
  }

  assert {
    condition     = length(output.managed_disk_ids) == 3
    error_message = "Default SQL data, log, and tempdb disks should be planned for one VM."
  }

  assert {
    condition     = output.tags.Owner == "CCOE"
    error_message = "Tags were not propagated."
  }
}

run "plan_two_named_sql_vms_with_storage_configuration" {
  command = plan

  variables {
    vm_count             = 2
    vm_names             = ["sqlappccprod001", "sqlappccprod002"]
    private_ip_addresses = ["10.10.10.10", "10.10.10.11"]
    zones                = ["1", "2"]
    sql_license_type     = "AHUB"
    storage_configuration = {
      disk_type             = "NEW"
      storage_workload_type = "OLTP"
      data_settings = {
        default_file_path = "F:\\SQLData"
        luns              = [0]
      }
      log_settings = {
        default_file_path = "G:\\SQLLog"
        luns              = [1]
      }
      temp_db_settings = {
        default_file_path      = "T:\\TempDB"
        luns                   = [2]
        data_file_count        = 4
        data_file_size_mb      = 256
        data_file_growth_in_mb = 256
        log_file_size_mb       = 256
        log_file_growth_mb     = 128
      }
    }
    sql_instance = {
      instant_file_initialization_enabled = true
      lock_pages_in_memory_enabled        = true
      max_dop                             = 4
      max_server_memory_mb                = 24576
      min_server_memory_mb                = 4096
    }
  }

  assert {
    condition     = output.names["0"] == "sqlappccprod001" && output.names["1"] == "sqlappccprod002"
    error_message = "Explicit SQL VM names were not preserved."
  }

  assert {
    condition     = length(output.managed_disk_ids) == 6 && length(output.sql_virtual_machine_ids) == 2
    error_message = "Two SQL VMs should plan six managed data disks and two SQL VM registrations."
  }
}

run "plan_domain_join_and_run_command" {
  command = plan

  variables {
    enable_domain_join          = true
    domain_name                 = "corp.example.com"
    domain_join_user            = "CORP\\joiner"
    domain_join_password        = "Terraform-Domain-Join-123!"
    run_command_replace_trigger = "v1"
    run_command = {
      name   = "SqlBootstrap"
      script = "Write-Output 'bootstrap'"
    }
  }

  assert {
    condition     = length(azurerm_virtual_machine_extension.domain_join) == 1 && length(azurerm_virtual_machine_run_command.this) == 1
    error_message = "Domain join and run command resources should be planned when enabled."
  }
}

run "reject_vm_name_count_mismatch" {
  command = plan

  variables {
    vm_count = 2
    vm_names = ["sqlonly001"]
  }

  expect_failures = [
    check.sqlvm_input_consistency,
  ]
}

run "reject_zones_with_availability_set" {
  command = plan

  variables {
    zones               = ["1"]
    availability_set_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-platform-prod/providers/Microsoft.Compute/availabilitySets/avail-sql-prod"
  }

  expect_failures = [
    check.sqlvm_input_consistency,
  ]
}
