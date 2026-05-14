resource "azurerm_data_factory" "this" {
  name                            = local.adf_name
  location                        = var.location
  resource_group_name             = var.resource_group
  public_network_enabled          = var.public_network_enabled
  managed_virtual_network_enabled = var.managed_virtual_network_enabled
  tags                            = local.merged_tags
  customer_managed_key_id         = var.customer_managed_key_id
  purview_id                      = var.purview_id

  identity {
    type         = var.identity_type
    identity_ids = contains(["UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type) ? var.identity_ids : null
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

  dynamic "github_configuration" {
    for_each = local.use_github_configuration ? [var.github_configuration] : []

    content {
      account_name    = var.github_configuration.account_name
      branch_name     = var.github_configuration.branch_name
      git_url         = var.github_configuration.git_url
      repository_name = var.github_configuration.repository_name
      root_folder     = var.github_configuration.root_folder
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

  location    = var.location
  app_vnet    = data.azurerm_virtual_network.app[0].name
  app_snet    = data.azurerm_subnet.app[0].name
  app_vnet_rg = data.azurerm_virtual_network.app[0].resource_group_name
  app_rg      = var.resource_group
  app_env     = var.app_env

  app_vm = var.app_vm

  iac_rg = data.azurerm_resource_group.iac.name
  iac_st = data.azurerm_storage_account.iac.name
  iac_kv = data.azurerm_key_vault.iac.name

  enable_shir                    = var.self_hosted_integration_runtime_enabled
  enable_custom_script_extension = true

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
  tags                = local.merged_tags

  private_service_connection {
    name                           = "pls-${local.adf_name}"
    private_connection_resource_id = azurerm_data_factory.this.id
    subresource_names              = ["datafactory"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "adf-df-zone-group"
    private_dns_zone_ids = [trimspace(var.private_dns_zone_id) != "" ? var.private_dns_zone_id : data.azurerm_private_dns_zone.adf_datafactory[0].id]
  }
}

resource "azurerm_role_assignment" "secret_user" {
  count                = contains(["SystemAssigned", "SystemAssigned, UserAssigned"], var.identity_type) ? 1 : 0
  scope                = data.azurerm_key_vault.iac.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_data_factory.this.identity[0].principal_id
  depends_on           = [azurerm_data_factory.this]
}
