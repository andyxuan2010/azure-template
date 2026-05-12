locals {
  region_code_map = {
    canadacentral  = "cc"
    canadaeast     = "ce"
    eastus         = "eus"
    eastus2        = "eus2"
    centralus      = "cus"
    southcentralus = "scus"
    northcentralus = "ncus"
    westus         = "wus"
    westus2        = "wus2"
    westus3        = "wus3"
  }
  suffix_map = {
    prod = "001"
    qa   = "301"
    dev  = "601"
    poc  = "701"
    test = "801"
    sbx  = "901"

  }
  suffix = lookup(local.suffix_map, var.environment, "000") # Default to "000" if env is undefined
}

locals {
  normalized_location = replace(replace(lower(var.location), " ", ""), "-", "")
  region_code         = lookup(local.region_code_map, local.normalized_location, substr(local.normalized_location, 0, 3))
  project_name        = trimspace(var.project)
  adf_name            = var.custom_adf_name == null ? "adf-${local.region_code}-${local.project_name}-${var.environment}-${local.suffix}" : var.custom_adf_name
  ir_name             = var.custom_default_ir_name == null ? "DefaultAutoResolve" : var.custom_default_ir_name
  shir_name           = var.custom_shir_name == null ? "shir-${local.project_name}-${var.environment}-${local.suffix}" : var.custom_shir_name
}

resource "azurerm_data_factory" "this" {
  name                            = local.adf_name
  location                        = var.location
  resource_group_name             = var.resource_group
  public_network_enabled          = var.public_network_enabled
  managed_virtual_network_enabled = var.managed_virtual_network_enabled
  #tags                            = var.tags

  tags = local.merged_tags


  identity {
    type = "SystemAssigned"
  }

  dynamic "global_parameter" {
    for_each = { for i in var.global_parameter : i.name => i if i.name != null }

    content {
      name  = global_parameter.value.name
      type  = global_parameter.value.type
      value = global_parameter.value.value
    }
  }

  dynamic "vsts_configuration" {
    for_each = local.use_vsts_configuration ? [var.vsts_configuration] : []

    content {
      account_name    = var.vsts_configuration.account_name
      branch_name     = var.vsts_configuration.branch_name
      project_name    = var.vsts_configuration.project_name
      repository_name = var.vsts_configuration.repository_name
      root_folder     = var.vsts_configuration.root_folder
      tenant_id       = var.vsts_configuration.tenant_id
    }
  }

  lifecycle {
    ignore_changes = [
      global_parameter,
    ]
  }
}

resource "azurerm_role_assignment" "data_factory" {
  for_each = {
    for permission in var.permissions : "${permission.object_id}-${permission.role}" => permission
    if permission.role != null
  }
  scope                = azurerm_data_factory.this.id
  role_definition_name = each.value.role
  principal_id         = each.value.object_id
}

resource "azurerm_data_factory_integration_runtime_azure" "auto_resolve" {
  data_factory_id         = azurerm_data_factory.this.id
  location                = "AutoResolve"
  name                    = local.ir_name
  time_to_live_min        = var.time_to_live_min
  virtual_network_enabled = var.virtual_network_enabled
  cleanup_enabled         = var.cleanup_enabled
  compute_type            = var.compute_type
  core_count              = var.core_count
}

resource "azurerm_data_factory_integration_runtime_self_hosted" "this" {
  count = var.self_hosted_integration_runtime_enabled ? 1 : 0

  name            = local.shir_name
  data_factory_id = azurerm_data_factory.this.id
  description     = "Self Hosted Integration Runtime for ${local.adf_name}"
  #depends_on = [module.shir[count.index].azurerm_windows_virtual_machine.this]
}

resource "azurerm_key_vault_secret" "shir_key1" {
  count        = var.self_hosted_integration_runtime_enabled ? 1 : 0
  name         = "adf-ccoe-default-shir-key"
  value        = azurerm_data_factory_integration_runtime_self_hosted.this[count.index].primary_authorization_key
  key_vault_id = data.azurerm_key_vault.iac.id
  content_type = "text/plain"
  depends_on   = [azurerm_data_factory_integration_runtime_self_hosted.this]
}
resource "azurerm_key_vault_secret" "default_key" {
  count        = var.self_hosted_integration_runtime_enabled ? 1 : 0
  name         = "adf-ccoe-shir-default-key"
  value        = azurerm_data_factory_integration_runtime_self_hosted.this[count.index].primary_authorization_key
  key_vault_id = data.azurerm_key_vault.iac.id
  content_type = "text/plain"
  depends_on   = [azurerm_data_factory_integration_runtime_self_hosted.this]
}
resource "azurerm_role_assignment" "app_admin_group" {
  for_each = merge(
    { for object_id in local.app_admin_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_admin : "name:${name}" => group.object_id }
  )

  scope                = azurerm_data_factory.this.id
  role_definition_name = "Contributor"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "app_user_group" {
  for_each = merge(
    { for object_id in local.app_user_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_user : "name:${name}" => group.object_id }
  )

  scope                = azurerm_data_factory.this.id
  role_definition_name = "Reader"
  principal_id         = each.value
}

# this is the example to create the SHIR- Self Hosted Integration Runtime
module "shir" {
  count  = var.self_hosted_integration_runtime_enabled ? 1 : 0
  source = "../winvm"
  # passing the data from the main.tf to the module
  location    = var.location
  app_vnet    = data.azurerm_virtual_network.app[0].name
  app_snet    = data.azurerm_subnet.app[0].name
  app_vnet_rg = data.azurerm_virtual_network.app[0].resource_group_name
  app_rg      = var.resource_group
  app_env     = var.app_env

  #app_vm  = local.shir_vm_name
  app_vm = var.app_vm

  iac_rg = data.azurerm_resource_group.iac.name
  iac_st = data.azurerm_storage_account.iac.name
  iac_kv = data.azurerm_key_vault.iac.name

  enable_shir                    = var.self_hosted_integration_runtime_enabled
  enable_custom_script_extension = true
  #LogFile    = "c:\\InitLog.txt"
  #AppRemoteGroup = var.app_user_group
  #AppAdminGroup  = var.app_admin_group

  app_remote_group = var.app_user_group
  app_admin_group  = var.app_admin_group
  depends_on       = [azurerm_data_factory.this, azurerm_data_factory_integration_runtime_self_hosted.this]
  tags             = local.merged_tags
  adf_id           = azurerm_data_factory.this.id
}

resource "azurerm_private_endpoint" "adf_datafactory" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "pep-${local.adf_name}"
  location            = var.location
  resource_group_name = var.resource_group
  subnet_id           = data.azurerm_subnet.app[0].id
  #tags                            = var.tags
  tags = local.merged_tags
  private_service_connection {
    name                           = "pls-${local.adf_name}"
    private_connection_resource_id = azurerm_data_factory.this.id
    subresource_names              = ["datafactory"] # <-- SHIR ↔ ADF control plane
    is_manual_connection           = false
  }
  # <-- attach your EXISTING zone here
  private_dns_zone_group {
    name                 = "adf-df-zone-group"
    private_dns_zone_ids = [trimspace(var.private_dns_zone_id) != "" ? var.private_dns_zone_id : data.azurerm_private_dns_zone.adf_datafactory[0].id]
  }
}


resource "azurerm_role_assignment" "secret_user" {
  scope                = data.azurerm_key_vault.iac.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_data_factory.this.identity[0].principal_id
  depends_on           = [azurerm_data_factory.this]
}


# # Optional: give Entra ID time to propagate the new MI object
# resource "time_sleep" "wait_for_mi" {
#   count           = var.self_hosted_integration_runtime_enabled ? 1 : 0
#   create_duration = "45s"
#   depends_on      = [module.shir]
# }
# resource "azurerm_role_assignment" "vm2adf" {
#   count           = var.self_hosted_integration_runtime_enabled ? 1 : 0
#   scope                = azurerm_data_factory.this.id
#   role_definition_name = "Data Factory Contributor"
#   principal_id         = module.shir[count.index].principal_id
#   #depends_on           = [azurerm_data_factory.this]
# }
