output "event_hubs" {
  description = "Key production namespace values."
  value = {
    namespace_id          = module.event_hubs.id
    namespace_name        = module.event_hubs.name
    principal_id          = module.event_hubs.principal_id
    eventhub_ids          = module.event_hubs.eventhub_ids
    consumer_group_ids    = module.event_hubs.consumer_group_ids
    private_endpoint_id   = module.event_hubs.private_endpoint_id
    diagnostic_setting_id = module.event_hubs.diagnostic_setting_id
  }
}
