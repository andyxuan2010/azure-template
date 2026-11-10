output "search_service" {
  description = "Key Azure AI Search deployment values."
  value = {
    id                              = module.search.id
    name                            = module.search.name
    endpoint                        = module.search.endpoint
    principal_id                    = module.search.principal_id
    private_endpoint_id             = module.search.private_endpoint_id
    shared_private_link_service_ids = module.search.shared_private_link_service_ids
    diagnostic_setting_id           = module.search.diagnostic_setting_id
  }
}
