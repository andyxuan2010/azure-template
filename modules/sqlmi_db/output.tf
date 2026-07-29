output "name" {
  description = "Name of the referenced SQL Managed Instance."
  value       = data.azurerm_mssql_managed_instance.this.name
}

output "administrator_login" {
  description = "Administrator login of the referenced SQL Managed Instance."
  value       = data.azurerm_mssql_managed_instance.this.administrator_login
  sensitive   = true
}

output "fqdn" {
  description = "Fully qualified domain name of the referenced SQL Managed Instance."
  value       = data.azurerm_mssql_managed_instance.this.fqdn
}
