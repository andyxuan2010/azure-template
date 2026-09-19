output "ai_services" {
  description = "Key Azure AI Services deployment values."
  value = {
    id                    = module.ai_services.id
    name                  = module.ai_services.name
    endpoint              = module.ai_services.endpoint
    principal_id          = module.ai_services.principal_id
    private_endpoint_id   = module.ai_services.private_endpoint_id
    diagnostic_setting_id = module.ai_services.diagnostic_setting_id
    deployment_ids        = module.ai_services.deployment_ids
    rai_policy_ids        = module.ai_services.rai_policy_ids
  }
}
