output "workspace" {
  description = "Key private workspace deployment values."
  value = {
    id                        = module.databricks.id
    name                      = module.databricks.name
    url                       = module.databricks.workspace_url
    managed_resource_group_id = module.databricks.managed_resource_group_id
    private_endpoint_ids      = module.databricks.private_endpoint_ids
    diagnostic_setting_id     = module.databricks.diagnostic_setting_id
  }
}
