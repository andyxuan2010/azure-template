# Assuming the resource group has not been created.
# data "azurerm_resource_group" "app" {
#   name = var.app_rg
# }

# resource "azurerm_resource_group" "app" {
#   #count    = length(data.azurerm_resource_group.app) == 0 ? 1 : 0
#   location = var.location
#   name     = var.app_rg
#   tags = merge(var.rg_tags, {
#     workload = var.workload
#     name     = var.app_rg
#   })
# }

# Assign the Reader role to the AD group for the resource group
# resource "azurerm_role_assignment" "reader" {
#   scope                = data.azurerm_resource_group.app.id
#   role_definition_name = "Reader"
#   principal_id         = var.app_user_group[0]
# }

# locals {
#   app_rg = length(try(data.azurerm_resource_group.app.name, "")) == 0 ? azurerm_resource_group.app[0].name : data.azurerm_resource_group.app.name
# }

# resource "azurerm_virtual_machine_extension" "AADLoginForWindows" {
#   count                      = var.AADLoginForWindows == true ? 1 : 0
#   name                       = "AADLoginForWindows"
#   virtual_machine_id         = azurerm_linux_virtual_machine.this.id
#   publisher                  = "Microsoft.Azure.ActiveDirectory"
#   type                       = "AADLoginForWindows"
#   type_handler_version       = "2.2"
#   auto_upgrade_minor_version = true
#   depends_on                 = [azurerm_linux_virtual_machine.this]
#   tags                       = var.rg_tags
#   lifecycle {
#     ignore_changes = [tags]
#   }
# }



# Create network interface if we need to have a static ip
resource "azurerm_network_interface" "this" {
  count               = var.app_vm_number
  name                = "nic-${var.app_vm}${format("%03d", local.suffix_base + count.index)}"
  location            = var.location
  resource_group_name = var.app_rg

  ip_configuration {
    name                          = "nicconfig-${var.workload}-cc-${local.subscription}"
    subnet_id                     = local.app_snet_id_effective
    public_ip_address_id          = var.public_network_enabled ? azurerm_public_ip.this[count.index].id : null
    private_ip_address_allocation = "Dynamic"
  }

  tags       = local.tags
  depends_on = [data.azurerm_resource_group.app]
}


resource "azurerm_virtual_machine_extension" "vm_extension_linux" {
  count                = var.enable_linux_vm_extension ? var.app_vm_number : 0
  name                 = "LocalizationScript"
  virtual_machine_id   = azurerm_linux_virtual_machine.this[count.index].id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  settings = jsonencode({
    timestamp = lookup(local.localization_vm_script_timestamps, "${azurerm_linux_virtual_machine.this[count.index].name}.sh", 0)
  })

  protected_settings = jsonencode({
    managedIdentity = {}
    script          = base64encode(local.vm_extension_localization_scripts[azurerm_linux_virtual_machine.this[count.index].name])
  })
  tags = local.tags
  depends_on = [
    azurerm_linux_virtual_machine.this,
    azurerm_role_assignment.vm2st_localization_reader,
    azurerm_storage_blob.localization_vm_script,
    azurerm_virtual_machine_data_disk_attachment.this
  ]
  lifecycle {
    ignore_changes = [tags]
    precondition {
      condition     = var.enable_system_assigned_identity
      error_message = "enable_linux_vm_extension requires enable_system_assigned_identity = true so the VM extension can authenticate to Azure Storage."
    }
  }
}

resource "azurerm_storage_blob" "localization_vm_script" {
  for_each = local.localization_vm_script_blob_names

  name                   = each.value
  storage_account_name   = local.iac_st_name_effective
  storage_container_name = var.localization_container_name
  type                   = "Block"
  source_content         = var.localization_vm_script_content[each.value]
  content_type           = "text/x-shellscript"
}


resource "azurerm_virtual_machine_extension" "entra_ssh_login" {
  count = var.enable_entra_ssh_login ? var.app_vm_number : 0

  name                       = "AADSSHLoginForLinux"
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADSSHLoginForLinux"
  type_handler_version       = "1.0"
  virtual_machine_id         = azurerm_linux_virtual_machine.this[count.index].id
  auto_upgrade_minor_version = true

  settings = jsonencode({
    install                  = true
    enableSSHD               = true
    enablePasswordAuth       = false
    enableSSHDKeyAuth        = true
    enableSSHDKeyAuthForRoot = true
    enableSSHDKeyAuthForUser = true
  })

  protected_settings = jsonencode({
    sshPublicKey = local.admin_ssh_key_effective
  })

  tags       = local.tags
  depends_on = [azurerm_linux_virtual_machine.this]
}

# resource "azurerm_virtual_machine_extension" "NetworkWatcherAgentWindows" {
#   name                       = "NetworkWatcherAgentLinux"
#   virtual_machine_id         = azurerm_linux_virtual_machine.this.id
#   publisher                  = "Microsoft.Azure.NetworkWatcher"
#   type                       = "NetworkWatcherAgentWindows"
#   type_handler_version       = "1.4"
#   auto_upgrade_minor_version = true
#   depends_on                 = [azurerm_windows_virtual_machine.this]
#   tags                       = var.rg_tags
#   lifecycle {
#     ignore_changes = [tags]
#   }
# }

resource "azurerm_linux_virtual_machine" "this" {
  count                           = var.app_vm_number
  name                            = "${var.app_vm}${format("%03d", local.suffix_base + count.index)}"
  computer_name                   = "${var.app_vm}${format("%03d", local.suffix_base + count.index)}"
  resource_group_name             = var.app_rg
  location                        = var.location
  zone                            = local.vm_zones[count.index]
  size                            = var.app_vm_size
  priority                        = var.enable_spot_instance ? "Spot" : "Regular"
  eviction_policy                 = var.enable_spot_instance ? var.spot_eviction_policy : null
  max_bid_price                   = var.enable_spot_instance ? var.spot_max_bid_price : null
  admin_username                  = local.admin_username_effective
  admin_password                  = local.admin_password_effective
  disable_password_authentication = false

  admin_ssh_key {
    username   = local.admin_username_effective
    public_key = local.admin_ssh_key_effective
  }
  network_interface_ids = [
    azurerm_network_interface.this[count.index].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  #az vm image list --publisher Canonical --output table
  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }
  dynamic "identity" {
    for_each = var.enable_system_assigned_identity ? [1] : []
    content {
      type = "SystemAssigned"
    }
  }

  patch_assessment_mode = "AutomaticByPlatform"
  # custom_data is a backup plan if the storage account is not accessible.
  # If post_init_script is provided, it is staged and executed after the base init.sh content completes.
  custom_data        = base64encode(local.init_script_final)
  provision_vm_agent = true
  #vm_agent_platform_updates_enabled = false
  tags = local.tags

  lifecycle {
    precondition {
      condition     = local.admin_username_effective != ""
      error_message = "azure-user must be provided for linuxvm."
    }

    precondition {
      condition     = local.admin_password_effective != ""
      error_message = "azure-password must be provided for linuxvm."
    }

    precondition {
      condition     = local.admin_ssh_key_effective != ""
      error_message = "azure-ssh-key must be provided for linuxvm."
    }
  }
}

resource "azurerm_managed_disk" "this" {
  count                 = var.disksize > 0 ? var.app_vm_number : 0 # Provision only if disksize > 0
  name                  = "${var.app_vm}${format("%03d", local.suffix_base + count.index)}-disk2"
  location              = var.location
  resource_group_name   = var.app_rg
  zone                  = local.vm_zones[count.index]
  storage_account_type  = "Standard_LRS"
  create_option         = "Empty"
  network_access_policy = "AllowAll"
  disk_size_gb          = var.disksize
  tags                  = local.tags
  depends_on            = [data.azurerm_resource_group.app, azurerm_linux_virtual_machine.this]
}

resource "azurerm_virtual_machine_data_disk_attachment" "this" {
  count              = var.disksize > 0 ? var.app_vm_number : 0 # Attach only if the disk exists
  managed_disk_id    = azurerm_managed_disk.this[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.this[count.index].id
  lun                = "0"
  caching            = "ReadWrite"
  depends_on         = [azurerm_managed_disk.this, azurerm_linux_virtual_machine.this]
}




resource "azurerm_role_assignment" "vm2st" {
  count = var.enable_system_assigned_identity ? var.app_vm_number : 0
  scope = local.iac_st_id_effective
  #scope                = data.azurerm_storage_container.scripts.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_virtual_machine.this[count.index].identity.0.principal_id
  depends_on           = [azurerm_linux_virtual_machine.this]
}

resource "azurerm_role_assignment" "vm2st_localization_reader" {
  count = var.enable_linux_vm_extension && var.enable_system_assigned_identity ? var.app_vm_number : 0
  scope = local.iac_st_id_effective

  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_linux_virtual_machine.this[count.index].identity.0.principal_id

  depends_on = [azurerm_linux_virtual_machine.this]
}
# resource "azurerm_role_assignment" "vm2st2" {
#   count               = var.app_vm_number
#   scope = data.azurerm_storage_account.iac.id
#   #scope                = data.azurerm_storage_container.scripts.id
#   role_definition_name = "Storage Blob Data List Contributor"
#   principal_id         = azurerm_linux_virtual_machine.this[count.index].identity.0.principal_id
#   depends_on           = [data.azurerm_storage_account.iac, azurerm_linux_virtual_machine.this]
# }

resource "azurerm_role_assignment" "vm2kv" {
  count                = var.enable_system_assigned_identity ? var.app_vm_number : 0
  scope                = local.iac_kv_id_effective
  role_definition_name = "Key Vault Reader"
  principal_id         = azurerm_linux_virtual_machine.this[count.index].identity.0.principal_id
  depends_on           = [azurerm_linux_virtual_machine.this]
}
resource "azurerm_role_assignment" "vm2kvsecrets" {
  count                = var.enable_system_assigned_identity ? var.app_vm_number : 0
  scope                = local.iac_kv_id_effective
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_virtual_machine.this[count.index].identity.0.principal_id
  depends_on           = [azurerm_linux_virtual_machine.this]
}

resource "azurerm_role_assignment" "vm_resource_admin" {
  for_each = local.vm_admin_role_assignments

  scope                = azurerm_linux_virtual_machine.this[each.value.vm_index].id
  role_definition_name = "Contributor"
  principal_id         = each.value.principal_id

  depends_on = [azurerm_linux_virtual_machine.this]
}

resource "azurerm_role_assignment" "nic_resource_admin" {
  for_each = local.vm_admin_role_assignments

  scope                = azurerm_network_interface.this[each.value.vm_index].id
  role_definition_name = "Contributor"
  principal_id         = each.value.principal_id

  depends_on = [azurerm_network_interface.this]
}

resource "azurerm_role_assignment" "vm_resource_user" {
  for_each = local.vm_user_role_assignments

  scope                = azurerm_linux_virtual_machine.this[each.value.vm_index].id
  role_definition_name = "Reader"
  principal_id         = each.value.principal_id

  depends_on = [azurerm_linux_virtual_machine.this]
}

resource "azurerm_role_assignment" "vm_entra_admin_login" {
  for_each = var.enable_entra_ssh_login ? local.vm_admin_role_assignments : {}

  scope                = azurerm_linux_virtual_machine.this[each.value.vm_index].id
  role_definition_name = "Virtual Machine Administrator Login"
  principal_id         = each.value.principal_id

  depends_on = [azurerm_linux_virtual_machine.this, azurerm_virtual_machine_extension.entra_ssh_login]
}

resource "azurerm_role_assignment" "vm_entra_user_login" {
  for_each = var.enable_entra_ssh_login ? local.vm_user_role_assignments : {}

  scope                = azurerm_linux_virtual_machine.this[each.value.vm_index].id
  role_definition_name = "Virtual Machine User Login"
  principal_id         = each.value.principal_id

  depends_on = [azurerm_linux_virtual_machine.this, azurerm_virtual_machine_extension.entra_ssh_login]
}



resource "azurerm_public_ip" "this" {
  count               = var.public_network_enabled == true ? var.app_vm_number : 0
  name                = "pip-${var.app_vm}${format("%03d", local.suffix_base + count.index)}"
  location            = var.location
  resource_group_name = var.app_rg
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
  depends_on          = [data.azurerm_resource_group.app]
}

resource "azurerm_network_security_group" "this" {
  count               = var.public_network_enabled == true ? var.app_vm_number : 0
  name                = "nsg-${var.app_vm}${format("%03d", local.suffix_base + count.index)}"
  location            = var.location
  resource_group_name = var.app_rg

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags       = local.tags
  depends_on = [data.azurerm_resource_group.app]
}

resource "azurerm_network_interface_security_group_association" "this" {
  count                     = var.public_network_enabled == true ? var.app_vm_number : 0
  network_interface_id      = azurerm_network_interface.this[count.index].id
  network_security_group_id = azurerm_network_security_group.this[count.index].id
  depends_on                = [azurerm_network_security_group.this, azurerm_network_interface.this]
}
