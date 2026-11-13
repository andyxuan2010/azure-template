mock_provider "azurerm" {
  mock_data "azurerm_client_config" {
    defaults = {
      subscription_id = "00000000-0000-0000-0000-000000000000"
      tenant_id       = "11111111-1111-1111-1111-111111111111"
    }
  }

  mock_data "azurerm_subnet" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-hub/subnets/snet-app"
    }
  }

  mock_data "azurerm_resource_group" {
    defaults = {
      id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-app"
      location = "canadacentral"
      tags = {
        Owner = "Platform"
      }
    }
  }

  mock_data "azurerm_key_vault_secret" {
    defaults = {
      id    = "https://kvplatformprod.vault.azure.net/secrets/datadog-api-key/0000000000000000000000000000000000"
      name  = "datadog-api-key"
      value = "0123456789abcdef0123456789abcdef"
    }
  }
}

mock_provider "azuread" {}

variables {
  location           = "canadacentral"
  app_env            = "prod"
  azure-user         = "azureadmin"
  azure-password     = "Mock-Password-Only-123!"
  AADLoginForWindows = false
  app_vm_number      = 2
  app_vm_size        = "Standard_D2s_v5"
  iac_rg             = "rg-platform"
  iac_kv             = "kvplatformprod"
  iac_st             = "stplatformprod"
  app_rg             = "rg-app"
  app_snet           = "snet-app"
  app_vnet_rg        = "rg-network"
  app_vnet           = "vnet-hub"
  app_vm             = "winapp"
  app_admin_group    = []
  app_user_group     = []
}

run "datadog_disabled_by_default" {
  command = plan

  assert {
    condition     = length(azurerm_virtual_machine_extension.datadog_windows) == 0
    error_message = "The Datadog extension must not be planned when enable_datadog_agent is false."
  }

  assert {
    condition     = length(data.azurerm_key_vault_secret.datadog_api_key) == 0
    error_message = "The Datadog key must not be read from Key Vault when enable_datadog_agent is false."
  }
}

run "datadog_enabled_with_input_key" {
  command = plan

  variables {
    enable_datadog_agent = true
    datadog_api_key      = "0123456789abcdef0123456789abcdef"
  }

  assert {
    condition     = length(azurerm_virtual_machine_extension.datadog_windows) == 2
    error_message = "One Datadog extension should be planned per VM when enabled (app_vm_number = 2)."
  }

  assert {
    condition     = azurerm_virtual_machine_extension.datadog_windows[0].type == "DatadogWindowsAgent" && azurerm_virtual_machine_extension.datadog_windows[0].publisher == "Datadog.Agent"
    error_message = "The Datadog extension must use publisher Datadog.Agent and type DatadogWindowsAgent."
  }

  assert {
    condition     = length(data.azurerm_key_vault_secret.datadog_api_key) == 0
    error_message = "An input key must take precedence and skip the Key Vault lookup."
  }
}

run "datadog_enabled_from_key_vault" {
  command = plan

  variables {
    enable_datadog_agent = true
    datadog_api_key      = null
  }

  assert {
    condition     = length(data.azurerm_key_vault_secret.datadog_api_key) == 1
    error_message = "A null input key should fall back to the iac_kv Key Vault secret."
  }

  assert {
    condition     = data.azurerm_key_vault_secret.datadog_api_key[0].name == "datadog-api-key"
    error_message = "Without a secret name override, the default secret datadog-api-key must be read."
  }

  assert {
    condition     = length(azurerm_virtual_machine_extension.datadog_windows) == 2
    error_message = "The Datadog extension should be planned when the Key Vault secret is valid."
  }
}

run "datadog_enabled_invalid_key_fails" {
  command = plan

  variables {
    enable_datadog_agent = true
    datadog_api_key      = "sample_api_key"
  }

  expect_failures = [
    azurerm_virtual_machine_extension.datadog_windows,
  ]
}

run "plan_private_multi_vm" {
  command = plan

  variables {
    private_ip_addresses = ["10.20.1.10", "10.20.1.11"]
  }

  assert {
    condition     = length(azurerm_windows_virtual_machine.this) == 2 && length(azurerm_network_interface.this) == 2
    error_message = "Expected two VMs and two NICs."
  }

  assert {
    condition     = azurerm_windows_virtual_machine.this[0].name == "winapp001" && azurerm_windows_virtual_machine.this[1].name == "winapp002"
    error_message = "Production VM suffixes were not generated correctly."
  }

  assert {
    condition     = length(azurerm_public_ip.this) == 0 && length(output.public_ips) == 0
    error_message = "Private VMs must not create public IPs."
  }

  assert {
    condition = (
      azurerm_network_interface.this[0].ip_configuration[0].private_ip_address_allocation == "Static" &&
      azurerm_network_interface.this[0].ip_configuration[0].private_ip_address == "10.20.1.10" &&
      azurerm_network_interface.this[1].ip_configuration[0].private_ip_address_allocation == "Static" &&
      azurerm_network_interface.this[1].ip_configuration[0].private_ip_address == "10.20.1.11"
    )
    error_message = "Static private IPs should be assigned in VM index order."
  }
}

run "plan_diagnostics" {
  command = plan

  variables {
    enable_diagnostics         = true
    log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-monitoring/providers/Microsoft.OperationalInsights/workspaces/log-platform"
  }

  assert {
    condition     = length(azurerm_monitor_diagnostic_setting.this) == 2 && output.diagnostics_enabled
    error_message = "Diagnostics must create one setting per VM."
  }
}

run "plan_restricted_public_rdp" {
  command = plan

  variables {
    app_vm_number               = 1
    public_network_enabled      = true
    rdp_source_address_prefixes = ["203.0.113.10/32"]
  }

  assert {
    condition     = length(azurerm_public_ip.this) == 1 && length(azurerm_network_security_group.this) == 1
    error_message = "Public networking must create one public IP and NSG per VM."
  }

  assert {
    condition     = contains(one(azurerm_network_security_group.this[0].security_rule).source_address_prefixes, "203.0.113.10/32")
    error_message = "The RDP rule must use the explicitly trusted source prefix."
  }
}

run "plan_primary_dns_suffix_override" {
  command = plan

  variables {
    app_vm_number        = 1
    enable_domain_join   = true
    domain_join_user     = "AERO\\join-account"
    domain_join_password = "Mock-Domain-Password-123!"
    primary_dns_suffix   = "ca.corp.contoso.com"
  }

  assert {
    condition     = length(azurerm_virtual_machine_run_command.primary_dns_suffix) == 1
    error_message = "A primary DNS suffix override must create one configuration command per VM."
  }

  assert {
    condition     = strcontains(azurerm_virtual_machine_run_command.primary_dns_suffix[0].source[0].script, "ca.corp.contoso.com")
    error_message = "The configuration command must contain the requested primary DNS suffix."
  }
}

run "plan_init2_primary_dns_suffix_argument" {
  command = plan

  variables {
    app_vm_number                          = 1
    enable_virtual_machine_run_command     = true
    init2_enable_domain_join               = true
    init2_domain_name                      = "corp.contoso.com"
    init2_domain_controller                = "dc01.corp.contoso.com"
    init2_domain_join_vault_name           = "kv-ccoe-cc-nonprod"
    init2_domain_join_password_secret_name = "domain-join-password"
    primary_dns_suffix                     = "ca.corp.contoso.com"
  }

  assert {
    condition = strcontains(
      nonsensitive(azurerm_virtual_machine_run_command.Init[0].source[0].script),
      "-PrimaryDnsSuffix"
      ) && strcontains(
      nonsensitive(azurerm_virtual_machine_run_command.Init[0].source[0].script),
      "ca.corp.contoso.com"
    )
    error_message = "The init2 Run Command must pass the configured primary DNS suffix to init2.ps1."
  }
}

run "plan_init2_without_primary_dns_suffix_argument" {
  command = plan

  variables {
    app_vm_number                          = 1
    enable_virtual_machine_run_command     = true
    init2_enable_domain_join               = true
    init2_domain_name                      = "corp.contoso.com"
    init2_domain_controller                = "dc01.corp.contoso.com"
    init2_domain_join_vault_name           = "kv-ccoe-cc-nonprod"
    init2_domain_join_password_secret_name = "domain-join-password"
    primary_dns_suffix                     = ""
  }

  assert {
    condition     = !strcontains(nonsensitive(azurerm_virtual_machine_run_command.Init[0].source[0].script), "-PrimaryDnsSuffix")
    error_message = "The init2 Run Command must omit the primary DNS suffix argument when no suffix is configured."
  }
}

run "custom_vm_names_override_vm_and_computer_name" {
  command = plan

  variables {
    custom_vm_names = ["idmweb01", "idmweb02"]
  }

  assert {
    condition     = azurerm_windows_virtual_machine.this[0].name == "idmweb01" && azurerm_windows_virtual_machine.this[1].name == "idmweb02"
    error_message = "custom_vm_names must set the Azure VM names verbatim."
  }

  assert {
    condition     = azurerm_windows_virtual_machine.this[0].computer_name == "idmweb01" && azurerm_windows_virtual_machine.this[1].computer_name == "idmweb02"
    error_message = "custom_vm_names must set the Windows computer names verbatim."
  }

  assert {
    condition     = azurerm_network_interface.this[1].name == "nic-idmweb02"
    error_message = "Dependent resource names must follow custom_vm_names."
  }
}

run "custom_vm_names_count_mismatch_fails" {
  command = plan

  variables {
    custom_vm_names = ["idmweb01"]
  }

  expect_failures = [
    azurerm_windows_virtual_machine.this,
  ]
}

run "custom_vm_names_too_long_fails" {
  command = plan

  variables {
    custom_vm_names = ["this-name-is-too-long", "idmweb02"]
  }

  expect_failures = [
    var.custom_vm_names,
  ]
}
