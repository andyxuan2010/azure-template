module "sqldb" {
  source  = "git::https://dev.azure.com/CCOE-Azure/CCoE-Infra-IaC/_git/template//modules/sqldb?ref=main"
  version = "1.0.0"

  resource_group_name = "my-resource-group"
  location            = "eastus"

  sql_server_name    = "my-sql-server"
  sql_admin_username = "sqladminuser"
  sql_admin_password = "MyStrongP@ssw0rd!"
  database_name      = "mydb"
  sku_name           = "S0"
}
