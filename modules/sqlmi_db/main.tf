

# data "azurerm_linux_virtual_machine" "win-cicd-id" {
#   name                = "AZUWASHA001"
#   resource_group_name = "rg-ba-cc-devops-ci-cd-prod"  # Resource group where the identity is created
# }

# data "azurerm_linux_virtual_machine" "linux-cicd-id" {
#   name                = "AZULASHA001"
#   resource_group_name = "rg-ba-cc-devops-ci-cd-prod"
# }

# data "azurerm_virtual_machine" "cicdvms" {
#   for_each            = toset(var.cicdvms)
#   name                = each.value
#   resource_group_name = "rg-ba-cc-devops-ci-cd-prod"
# }
# resource "azurerm_role_assignment" "sqlmi_contributors" {
#   for_each            = data.azurerm_virtual_machine.cicdvms
#   scope                = data.azurerm_mssql_managed_instance.this.id
#   role_definition_name = "Contributor"
#   principal_id         = each.value.identity[0].principal_id
# }

# resource "azurerm_role_assignment" "sqlmi_contributor_win" {
#   scope                = data.azurerm_mssql_managed_instance.this.id
#   role_definition_name = "Contributor"
#   principal_id         = data.azurerm_user_assigned_identity.win-cicd-id.principal_id
# }
# resource "azurerm_role_assignment" "sqlmi_contributor_linux" {
#   scope                = data.azurerm_mssql_managed_instance.this.id
#   role_definition_name = "Contributor"
#   principal_id         = data.azurerm_user_assigned_identity.linux-cicd-id.principal_id
# }

resource "azurerm_mssql_managed_database" "this" {
  name                = local.database_name
  managed_instance_id = data.azurerm_mssql_managed_instance.this.id
  tags                = local.tags
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "${azurerm_mssql_managed_database.this.name}-diagnostic"
  target_resource_id         = azurerm_mssql_managed_database.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = toset(var.diagnostic_log_categories)

    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = toset(var.diagnostic_metric_categories)

    content {
      category = enabled_metric.value
    }
  }
}

resource "azurerm_role_assignment" "app_admin_group" {
  for_each = merge(
    { for object_id in local.app_admin_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_admin : "name:${name}" => group.object_id }
  )

  scope                = azurerm_mssql_managed_database.this.id
  role_definition_name = "Contributor"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "app_admin_group_managed_instance" {
  for_each = merge(
    { for object_id in local.app_admin_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_admin : "name:${name}" => group.object_id }
  )

  scope                = data.azurerm_mssql_managed_instance.this.id
  role_definition_name = "Reader"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "app_user_group" {
  for_each = merge(
    { for object_id in local.app_user_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_user : "name:${name}" => group.object_id }
  )

  scope                = azurerm_mssql_managed_database.this.id
  role_definition_name = "Reader"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "app_user_group_managed_instance" {
  for_each = merge(
    { for object_id in local.app_user_group_object_ids : "id:${object_id}" => object_id },
    { for name, group in data.azuread_group.app_user : "name:${name}" => group.object_id }
  )

  scope                = data.azurerm_mssql_managed_instance.this.id
  role_definition_name = "Reader"
  principal_id         = each.value
}

# resource "azurerm_role_assignment" "vm2mi" {
#   scope                = data.azurerm_mssql_managed_instance.this.id
#   role_definition_name = "reader"
#   principal_id         = azurerm_linux_virtual_machine.this.identity.0.principal_id
#   depends_on           = [data.azurerm_storage_account.iac, azurerm_linux_virtual_machine.this]
# }

# resource "azurerm_role_assignment" "app2mi" {
#   scope                = data.azurerm_mssql_managed_instance.this.id
#   role_definition_name = "reader"
#   principal_id         = data.azuread_group.app.object_id
# }
# resource "azurerm_role_assignment" "vm2kv" {
#   scope                = data.azurerm_key_vault.iac.id
#   role_definition_name = "Key Vault Reader"
#   principal_id         = azurerm_linux_virtual_machine.this.identity.0.principal_id
#   depends_on           = [data.azurerm_key_vault.iac, azurerm_linux_virtual_machine.this]
# }
# resource "azurerm_role_assignment" "vm2kvsecrets" {
#   scope                = data.azurerm_key_vault.iac.id
#   role_definition_name = "Key Vault Secrets User"
#   principal_id         = azurerm_linux_virtual_machine.this.identity.0.principal_id
#   depends_on           = [data.azurerm_key_vault.iac, azurerm_linux_virtual_machine.this]
# }

# try to create a user in the database
# resource "null_resource" "create_sql_users" {
#   depends_on = [azurerm_mssql_managed_database.this]

#   provisioner "local-exec" {
#     command = <<EOT
#       sqlcmd -S ${data.azurerm_mssql_managed_instance.this.fqdn} -U ${data.azurerm_mssql_managed_instance.this.administrator_login} -P "${data.azurerm_key_vault_secret.sqladminuser-password.value}" -Q "CREATE LOGIN [${var.sql_ad_group}] FROM EXTERNAL PROVIDER;"
#       sqlcmd -S ${data.azurerm_mssql_managed_instance.this.fqdn} -d ${azurerm_mssql_managed_database.this.name} -U ${data.azurerm_mssql_managed_instance.this.administrator_login} -P "${data.azurerm_key_vault_secret.sqladminuser-password.value}" -Q "CREATE USER [${var.sql_ad_group}] FROM EXTERNAL PROVIDER;ALTER ROLE db_owner ADD MEMBER [${var.sql_ad_group}];"
#     EOT
#   }
# }

