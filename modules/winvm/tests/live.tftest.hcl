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
}

mock_provider "azuread" {}
mock_provider "azapi" {}

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

run "plan_private_multi_vm" {
  command = plan

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
