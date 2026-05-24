output "name" {
  value = data.azurerm_mssql_managed_instance.this.name
}

output "administrator_login" {
  value = data.azurerm_mssql_managed_instance.this.administrator_login
}

output "fqdn" {
  value = data.azurerm_mssql_managed_instance.this.fqdn
}