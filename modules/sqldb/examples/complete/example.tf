module "sqldb" {
  source = "../../"

  resource_group_name = "rg-demo-dev"
  location            = "canadacentral"
  server_name         = "sql-demo-dev-001"
  name                = "sqldb-demo-dev-001"
  app_env             = "dev"
  sku_name            = "Basic"
  max_size_gb         = 2

  admin_username      = "sqladminuser"
  admin_password      = var.sql_admin_password
  ad_admin_login_name = "sql-admin-group"
  ad_admin_object_id  = var.sql_admin_group_object_id

  enable_private_endpoint       = false
  public_network_access_enabled = true

  firewall_rules = {
    office = {
      start_ip_address = "203.0.113.10"
      end_ip_address   = "203.0.113.10"
    }
  }

  tags = {
    Owner = "CCOE"
    IaC   = "Terraform"
  }
}

variable "sql_admin_password" {
  type        = string
  description = "SQL admin password for the demo example."
  sensitive   = true
}

variable "sql_admin_group_object_id" {
  type        = string
  description = "Microsoft Entra object ID for the SQL administrator group."
}
