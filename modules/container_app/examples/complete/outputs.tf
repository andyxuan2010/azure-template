output "container_app" {
  description = "Key deployment values."
  value = {
    id                   = module.container_app.id
    name                 = module.container_app.name
    latest_revision_name = module.container_app.latest_revision_name
    fqdn                 = module.container_app.latest_revision_fqdn
    principal_id         = module.container_app.principal_id
  }
}
