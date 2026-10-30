# Copyright (c) CCOE-Azure.
# SPDX-License-Identifier: Proprietary
#
# Module: sqlvm
# Description: Deploys one or more Windows SQL Server virtual machines on Azure and registers them with the SQL IaaS extension.
#              The module creates network interfaces, Windows VMs, managed SQL data disks, disk attachments, optional domain join, optional VM Run Command bootstrap, and SQL VM configuration for licensing, storage, backup, patching, assessment, and connectivity settings. It supports generated or explicit VM names, availability zones or availability sets, static or dynamic private IPs, and resource group tag inheritance for governance alignment.
# Owner: Cloud Center of Excellence (CCOE)
# Maintainer: Andy Xuan@CCOE
# Repository: CCOE-Azure/azure-template
#
# Created: 2026-07-07
# Modified: 2026-07-08
# Version: 1.3.0
#
# Change History:
# - 2026-07-07 v1.0.0: Established reusable sqlvm module baseline for the CCOE Azure IaC template library.
# - 2026-07-08 v1.0.0: Added standardized module metadata header with ownership, maintainer, license, dates, version, and change history.
#
# This Terraform module is maintained as part of the CCOE Azure IaC template library.
# Use, modification, and distribution are governed by the repository license and organizational policy.

check "sqlvm_input_consistency" {
  assert {
    condition     = length(var.vm_names) == 0 || length(var.vm_names) == var.vm_count
    error_message = "vm_names must be empty or contain exactly one name per SQL VM."
  }

  assert {
    condition     = length(var.private_ip_addresses) == 0 || length(var.private_ip_addresses) == var.vm_count
    error_message = "private_ip_addresses must be empty or contain exactly one private IP per SQL VM."
  }

  assert {
    condition     = var.availability_set_id == null || length(var.zones) == 0
    error_message = "availability_set_id and zones are mutually exclusive for Azure VMs."
  }

  assert {
    condition     = !var.enable_domain_join || (trimspace(var.domain_name) != "" && trimspace(var.domain_join_user) != "" && trimspace(nonsensitive(var.domain_join_password)) != "")
    error_message = "domain_name, domain_join_user, and domain_join_password are required when enable_domain_join is true."
  }
}

resource "azurerm_network_interface" "this" {
  for_each = local.instances

  name                = "nic-${each.value.name}"
  location            = local.resolved_location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig-${each.value.name}"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = each.value.private_ip == null ? "Dynamic" : "Static"
    private_ip_address            = each.value.private_ip
  }

  tags = local.tags
}

resource "azurerm_windows_virtual_machine" "this" {
  for_each = local.instances

  name                = each.value.name
  computer_name       = each.value.computer_name
  location            = local.resolved_location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  zone                = var.availability_set_id == null ? each.value.zone : null
  availability_set_id = var.availability_set_id
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  license_type        = var.windows_license_type

  network_interface_ids = [
    azurerm_network_interface.this[each.key].id,
  ]

  os_disk {
    caching              = var.os_disk.caching
    storage_account_type = var.os_disk.storage_account_type
    disk_size_gb         = var.os_disk.disk_size_gb
  }

  source_image_reference {
    publisher = var.source_image_reference.publisher
    offer     = var.source_image_reference.offer
    sku       = var.source_image_reference.sku
    version   = var.source_image_reference.version
  }

  dynamic "identity" {
    for_each = var.identity == null ? [] : [var.identity]

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  patch_mode            = var.patch_mode
  patch_assessment_mode = var.patch_assessment_mode
  provision_vm_agent    = true
  tags                  = local.tags

  lifecycle {
    ignore_changes = [
      admin_password,
    ]
  }
}

resource "azurerm_managed_disk" "this" {
  for_each = local.data_disk_instances

  name                 = "disk-${each.value.disk_key}-${each.value.vm_name}"
  location             = local.resolved_location
  resource_group_name  = var.resource_group_name
  zone                 = each.value.zone
  storage_account_type = each.value.storage_account_type
  create_option        = "Empty"
  disk_size_gb         = each.value.disk_size_gb
  disk_iops_read_write = each.value.disk_iops_read_write
  disk_mbps_read_write = each.value.disk_mbps_read_write
  tags                 = local.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "this" {
  for_each = local.data_disk_instances

  managed_disk_id    = azurerm_managed_disk.this[each.key].id
  virtual_machine_id = azurerm_windows_virtual_machine.this[each.value.vm_key].id
  lun                = each.value.lun
  caching            = each.value.caching
}

resource "azurerm_virtual_machine_extension" "domain_join" {
  for_each = var.enable_domain_join ? local.instances : {}

  name                       = "JsonADDomainExtension"
  virtual_machine_id         = azurerm_windows_virtual_machine.this[each.key].id
  publisher                  = "Microsoft.Compute"
  type                       = "JsonADDomainExtension"
  type_handler_version       = "1.3"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    Name    = var.domain_name
    OUPath  = var.domain_ou_path
    User    = var.domain_join_user
    Restart = tostring(var.domain_join_restart)
    Options = tostring(var.domain_join_options)
  })

  protected_settings = jsonencode({
    Password = var.domain_join_password
  })

  tags = local.tags
}

resource "terraform_data" "run_command_replace_trigger" {
  input = var.run_command_replace_trigger
}

resource "azurerm_virtual_machine_run_command" "this" {
  for_each = var.run_command == null ? {} : local.instances

  name               = var.run_command.name
  location           = local.resolved_location
  virtual_machine_id = azurerm_windows_virtual_machine.this[each.key].id

  source {
    script = var.run_command.script
  }

  lifecycle {
    replace_triggered_by = [
      terraform_data.run_command_replace_trigger,
    ]
  }

  tags = local.tags

  depends_on = [
    azurerm_virtual_machine_extension.domain_join,
  ]
}

resource "azurerm_mssql_virtual_machine" "this" {
  for_each = var.enable_sql_iaas_extension ? local.instances : {}

  virtual_machine_id               = azurerm_windows_virtual_machine.this[each.key].id
  sql_license_type                 = var.sql_license_type
  sql_connectivity_type            = var.sql_connectivity.type
  sql_connectivity_port            = var.sql_connectivity.port
  sql_connectivity_update_username = var.sql_connectivity.update_username
  sql_connectivity_update_password = var.sql_connectivity.update_password
  r_services_enabled               = var.r_services_enabled
  sql_virtual_machine_group_id     = var.sql_virtual_machine_group_id
  tags                             = local.tags

  dynamic "sql_instance" {
    for_each = var.sql_instance == null ? [] : [var.sql_instance]

    content {
      adhoc_workloads_optimization_enabled = sql_instance.value.adhoc_workloads_optimization_enabled
      collation                            = sql_instance.value.collation
      instant_file_initialization_enabled  = sql_instance.value.instant_file_initialization_enabled
      lock_pages_in_memory_enabled         = sql_instance.value.lock_pages_in_memory_enabled
      max_dop                              = sql_instance.value.max_dop
      max_server_memory_mb                 = sql_instance.value.max_server_memory_mb
      min_server_memory_mb                 = sql_instance.value.min_server_memory_mb
    }
  }

  dynamic "storage_configuration" {
    for_each = var.storage_configuration == null ? [] : [var.storage_configuration]

    content {
      disk_type                      = storage_configuration.value.disk_type
      storage_workload_type          = storage_configuration.value.storage_workload_type
      system_db_on_data_disk_enabled = storage_configuration.value.system_db_on_data_disk_enabled

      dynamic "data_settings" {
        for_each = storage_configuration.value.data_settings == null ? [] : [storage_configuration.value.data_settings]

        content {
          default_file_path = data_settings.value.default_file_path
          luns              = data_settings.value.luns
        }
      }

      dynamic "log_settings" {
        for_each = storage_configuration.value.log_settings == null ? [] : [storage_configuration.value.log_settings]

        content {
          default_file_path = log_settings.value.default_file_path
          luns              = log_settings.value.luns
        }
      }

      dynamic "temp_db_settings" {
        for_each = storage_configuration.value.temp_db_settings == null ? [] : [storage_configuration.value.temp_db_settings]

        content {
          default_file_path      = temp_db_settings.value.default_file_path
          luns                   = temp_db_settings.value.luns
          data_file_count        = temp_db_settings.value.data_file_count
          data_file_size_mb      = temp_db_settings.value.data_file_size_mb
          data_file_growth_in_mb = temp_db_settings.value.data_file_growth_in_mb
          log_file_size_mb       = temp_db_settings.value.log_file_size_mb
          log_file_growth_mb     = temp_db_settings.value.log_file_growth_mb
        }
      }
    }
  }

  dynamic "auto_patching" {
    for_each = var.auto_patching == null ? [] : [var.auto_patching]

    content {
      day_of_week                            = auto_patching.value.day_of_week
      maintenance_window_duration_in_minutes = auto_patching.value.maintenance_window_duration_in_minutes
      maintenance_window_starting_hour       = auto_patching.value.maintenance_window_starting_hour
    }
  }

  dynamic "assessment" {
    for_each = var.assessment == null ? [] : [var.assessment]

    content {
      enabled         = assessment.value.enabled
      run_immediately = assessment.value.run_immediately

      dynamic "schedule" {
        for_each = assessment.value.schedule == null ? [] : [assessment.value.schedule]

        content {
          day_of_week        = schedule.value.day_of_week
          monthly_occurrence = schedule.value.monthly_occurrence
          start_time         = schedule.value.start_time
          weekly_interval    = schedule.value.weekly_interval
        }
      }
    }
  }

  dynamic "auto_backup" {
    for_each = var.auto_backup == null ? [] : [var.auto_backup]

    content {
      retention_period_in_days        = auto_backup.value.retention_period_in_days
      storage_account_access_key      = auto_backup.value.storage_account_access_key
      storage_blob_endpoint           = auto_backup.value.storage_blob_endpoint
      system_databases_backup_enabled = auto_backup.value.system_databases_backup_enabled
      encryption_password             = auto_backup.value.encryption_password

      dynamic "manual_schedule" {
        for_each = auto_backup.value.manual_schedule == null ? [] : [auto_backup.value.manual_schedule]

        content {
          days_of_week                    = manual_schedule.value.days_of_week
          full_backup_frequency           = manual_schedule.value.full_backup_frequency
          full_backup_start_hour          = manual_schedule.value.full_backup_start_hour
          full_backup_window_in_hours     = manual_schedule.value.full_backup_window_in_hours
          log_backup_frequency_in_minutes = manual_schedule.value.log_backup_frequency_in_minutes
        }
      }
    }
  }

  dynamic "key_vault_credential" {
    for_each = var.key_vault_credential == null ? [] : [var.key_vault_credential]

    content {
      name                     = key_vault_credential.value.name
      key_vault_url            = key_vault_credential.value.key_vault_url
      service_principal_name   = key_vault_credential.value.service_principal_name
      service_principal_secret = key_vault_credential.value.service_principal_secret
    }
  }

  dynamic "wsfc_domain_credential" {
    for_each = var.wsfc_domain_credential == null ? [] : [var.wsfc_domain_credential]

    content {
      cluster_bootstrap_account_password = wsfc_domain_credential.value.cluster_bootstrap_account_password
      cluster_operator_account_password  = wsfc_domain_credential.value.cluster_operator_account_password
      sql_service_account_password       = wsfc_domain_credential.value.sql_service_account_password
    }
  }

  depends_on = [
    azurerm_virtual_machine_data_disk_attachment.this,
    azurerm_virtual_machine_extension.domain_join,
  ]
}
