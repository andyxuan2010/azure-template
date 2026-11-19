mock_provider "azurerm" {
  mock_data "azurerm_client_config" {
    defaults = {
      subscription_id = "00000000-0000-0000-0000-000000000000"
    }
  }

  mock_data "azurerm_resource_group" {
    defaults = {
      id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ccoe-iac-cc-dev"
      name     = "rg-ccoe-iac-cc-dev"
      location = "canadacentral"
    }
  }

  mock_data "azurerm_key_vault_secret" {
    defaults = {
      id    = "https://kv-ccoe-cc-prod.vault.azure.net/secrets/datadog-api-key/0000000000000000000000000000000000"
      name  = "datadog-api-key"
      value = "0123456789abcdef0123456789abcdef"
    }
  }
}

variables {
  tags = {
    "Application Name"                  = "CCOE INFRA IAC"
    "Application Owner"                 = "CCOE"
    "AppSupport Team"                   = "CCOE"
    "Approval Group"                    = "CCOE"
    "Business Owner"                    = "CCOE"
    "environment"                       = "Prod"
    "Infra Availability Classification" = "Bronze"
    "InfraSupport Team"                 = "CCOE"
    "Maintenance Window"                = "CCOE"
    "Project Name"                      = "CCOE INFRA IAC"
    "Project Number"                    = "N/A"
    "RPO-RTO"                           = "48H/24H"
    "Run Cost(Approved Run Budget)-USD" = "100"
    "Project Status"                    = "test"
    "workload"                          = "iactest"
    "IaC"                               = "Terraform"
    "Requested By"                      = "CCOE"
    "Provisioned By"                    = "CCOE"
    "Technical contact"                 = "CCOE"
    "Business contact"                  = "CCOE"
    "ADO Project"                       = "CCoE-Infra-IaC"
    "ADO Repo"                          = "adf-lab"
    "ADO Link"                          = "https://dev.azure.com/CCOE-Azure/CCoE-Infra-IaC/_git/adf-lab"
  }
  location         = "canadacentral"
  app_env          = "prod"
  workload         = "iactest"
  admin_username   = "azureadmin"
  admin_password   = "TerraformLiveTest-ChangeMe123!"
  admin_ssh_key    = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDpC2+ri1pCn9Q9YE4z9aZ+0fYXYek/okCGcR7qvhvURHlQZ6N34wd3U4lbefrxvXNxPsijmil89qx3ThglAc4cbjcBkjJ9iLUIqF5J76MM4U2rDJUQxSPDMt89Z1geBIdhwCZatjZ1gVmrq8bbJZtxltmShImk21rWAmLFf31dve2gVdmPtaURYlpRoMSb3bUyifoY0+F7W+vDkGKfcOvLrBNDQYMmOJ5x5Meiw3ozrVtV22FeDPzkAIMF6WQrErU67lmAIenC9pvRfMtgOTzGIgwQdZzMK3KZgNjA4f5Xs/tvWocrTEzU8j3JXISMDEm/qhbAdC8C3P4Tjo/csUhF terraform-live-test"
  post_init_script = ""

  # Authentication and identity options
  enable_system_assigned_identity = true
  enable_entra_ssh_login          = false
  enable_domain_join              = false
  enable_zone_spread              = true
  availability_zones              = ["1", "2", "3"]

  # Optional post-bootstrap localization extension
  enable_linux_vm_extension   = false
  localization_container_name = "localization"
  localization_os_script_name = "ubuntu.sh"

  datadog_api_key              = "sample_api_key"
  data_disk_size_gb            = 100
  vm_count                     = 1
  vm_size                      = "Standard_B2s"
  enable_spot_instance         = false
  spot_eviction_policy         = "Deallocate"
  spot_max_bid_price           = -1
  image_publisher              = "Canonical"
  image_offer                  = "ubuntu-24_04-lts"
  image_sku                    = "server"
  image_version                = "latest"
  iac_rg                       = "rg-ccoe-iac-cc-prod"
  iac_kv                       = "kv-ccoe-cc-prod"
  iac_kv_id                    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-iac/providers/Microsoft.KeyVault/vaults/kv-ccoe-cc-prod"
  iac_st                       = "stccoeiacprod"
  iac_st_id                    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-iac/providers/Microsoft.Storage/storageAccounts/stccoeiacprod"
  iac_st_primary_blob_endpoint = "https://stccoeiacprod.blob.core.windows.net/"
  resource_group_name          = "rg-ccoe-iac-cc-dev"
  subnet_name                  = "snet-ba-cc-prod-hub-sysmgmt"
  vnet_resource_group_name     = "rg-ba-cc-prod-hub-network"
  vnet_name                    = "vnet-ba-cc-prod-hub"
  vm_name                      = "azuliccoejmp"
  domain                       = "2join.us"
  domain_join_ou               = "azure"
  app_admin_group              = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
  app_user_group               = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
  public_network_enabled       = false
  subnet_id                    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-ba-cc-prod-hub/subnets/snet-ba-cc-prod-hub-sysmgmt"
  bastion_resource_name        = ""
  inherited_resource_group_tags = {
    CostCenter = "platform"
  }
}

run "plan" {
  command = plan

  assert {
    condition     = length(output.name) == 1
    error_message = "One Linux VM should be planned."
  }

  assert {
    condition     = output.tags.CostCenter == "platform"
    error_message = "Inherited resource-group tags were not applied."
  }
}

run "datadog_disabled_by_default" {
  command = plan

  assert {
    condition     = length(azurerm_virtual_machine_extension.datadog_linux) == 0
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
    condition     = length(azurerm_virtual_machine_extension.datadog_linux) == 1
    error_message = "One Datadog extension should be planned per VM when enabled."
  }

  assert {
    condition     = azurerm_virtual_machine_extension.datadog_linux[0].type == "DatadogLinuxAgent" && azurerm_virtual_machine_extension.datadog_linux[0].publisher == "Datadog.Agent"
    error_message = "The Datadog extension must use publisher Datadog.Agent and type DatadogLinuxAgent."
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
    error_message = "A null input key should fall back to the iac_kv_id Key Vault secret."
  }

  assert {
    condition     = data.azurerm_key_vault_secret.datadog_api_key["active"].name == "datadog-api-key"
    error_message = "Without a secret name override, the default secret datadog-api-key must be read."
  }

  assert {
    condition     = length(azurerm_virtual_machine_extension.datadog_linux) == 1
    error_message = "The Datadog extension should be planned when the Key Vault secret is valid."
  }
}

run "datadog_enabled_custom_secret_name" {
  command = plan

  variables {
    enable_datadog_agent        = true
    datadog_api_key             = ""
    datadog_api_key_secret_name = "dd-prod-key"
  }

  assert {
    condition     = length(data.azurerm_key_vault_secret.datadog_api_key) == 1 && data.azurerm_key_vault_secret.datadog_api_key["active"].name == "dd-prod-key"
    error_message = "An empty input key with a secret name should read that named secret."
  }
}

run "datadog_enabled_invalid_key_fails" {
  command = plan

  variables {
    enable_datadog_agent = true
    datadog_api_key      = "sample_api_key"
  }

  expect_failures = [
    azurerm_virtual_machine_extension.datadog_linux,
  ]
}

run "plan_localization_blob" {
  command = plan

  variables {
    localization_vm_script_content = {
      "ubuntu.sh" = <<-EOT
        #!/usr/bin/env bash
        exit 0
      EOT
    }
  }

  assert {
    condition     = azurerm_storage_blob.localization_vm_script["ubuntu.sh"].storage_container_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-iac/providers/Microsoft.Storage/storageAccounts/stccoeiacprod/blobServices/default/containers/localization"
    error_message = "Localization scripts must target the storage container resource ID."
  }
}

run "plan_localization_extension_mixed_file_uris" {
  command = plan

  variables {
    enable_linux_vm_extension   = true
    vm_count                    = 2
    custom_vm_names             = ["idm-app-01", "idm-app-02"]
    private_ip_addresses        = []
    localization_os_script_name = ""
    localization_vm_script_content = {
      "idm-app-01.sh" = <<-EOT
        #!/usr/bin/env bash
        exit 0
      EOT
    }
  }

  assert {
    condition     = length(azurerm_virtual_machine_extension.vm_extension_linux) == 2
    error_message = "Each Linux VM should get a localization extension."
  }

  assert {
    condition     = !strcontains(nonsensitive(azurerm_virtual_machine_extension.vm_extension_linux[0].protected_settings), "fileUris")
    error_message = "A VM with embedded script content must not download files."
  }

  assert {
    condition     = strcontains(nonsensitive(azurerm_virtual_machine_extension.vm_extension_linux[1].protected_settings), "https://stccoeiacprod.blob.core.windows.net/localization/idm-app-02.sh")
    error_message = "A VM without embedded script content must download its script through fileUris."
  }
}

run "plan_group_and_bastion_rbac" {
  command = plan

  variables {
    app_admin_group             = ["11111111-1111-1111-1111-111111111111"]
    app_user_group              = ["22222222-2222-2222-2222-222222222222"]
    bastion_resource_name       = "bas-prod"
    bastion_resource_group_name = "rg-network-prod"
  }

  assert {
    condition     = length(azurerm_role_assignment.resource_group_reader) == 2
    error_message = "Both access groups should receive Reader on the VM resource group."
  }

  assert {
    condition     = length(azurerm_role_assignment.bastion_network_contributor) == 2
    error_message = "Both access groups should receive Network Contributor on Bastion."
  }
}

run "plan_static_private_ips_multi_vm" {
  command = plan

  variables {
    vm_count             = 2
    private_ip_addresses = ["10.10.1.10", "10.10.1.11"]
  }

  assert {
    condition     = length(azurerm_network_interface.this) == 2
    error_message = "Expected one Linux NIC per VM."
  }

  assert {
    condition = (
      azurerm_network_interface.this[0].ip_configuration[0].private_ip_address_allocation == "Static" &&
      azurerm_network_interface.this[0].ip_configuration[0].private_ip_address == "10.10.1.10" &&
      azurerm_network_interface.this[1].ip_configuration[0].private_ip_address_allocation == "Static" &&
      azurerm_network_interface.this[1].ip_configuration[0].private_ip_address == "10.10.1.11"
    )
    error_message = "Static private IPs should be assigned in VM index order."
  }
}

run "custom_vm_names_default_keeps_generated_pattern" {
  command = plan

  assert {
    condition     = azurerm_linux_virtual_machine.this[0].name == "azuliccoejmp001" && azurerm_linux_virtual_machine.this[0].computer_name == "azuliccoejmp001"
    error_message = "Without custom_vm_names the generated <name><suffix> pattern must be unchanged."
  }
}

run "custom_vm_names_override_vm_and_hostname" {
  command = plan

  variables {
    vm_count             = 2
    custom_vm_names      = ["idm-app-01", "idm-app-02"]
    private_ip_addresses = []
  }

  assert {
    condition     = azurerm_linux_virtual_machine.this[0].name == "idm-app-01" && azurerm_linux_virtual_machine.this[1].name == "idm-app-02"
    error_message = "custom_vm_names must set the Azure VM names verbatim."
  }

  assert {
    condition     = azurerm_linux_virtual_machine.this[0].computer_name == "idm-app-01" && azurerm_linux_virtual_machine.this[1].computer_name == "idm-app-02"
    error_message = "custom_vm_names must set the hostnames verbatim."
  }

  assert {
    condition     = azurerm_network_interface.this[0].name == "nic-idm-app-01"
    error_message = "Dependent resource names must follow custom_vm_names."
  }
}

run "custom_vm_names_count_mismatch_fails" {
  command = plan

  variables {
    vm_count        = 2
    custom_vm_names = ["idm-app-01"]
  }

  expect_failures = [
    azurerm_linux_virtual_machine.this,
  ]
}

run "custom_vm_names_invalid_name_fails" {
  command = plan

  variables {
    custom_vm_names = ["-bad_name"]
  }

  expect_failures = [
    var.custom_vm_names,
  ]
}
