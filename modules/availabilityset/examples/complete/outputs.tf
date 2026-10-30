output "availability_set" {
  description = "Availability Set values used by downstream VM compositions."
  value = {
    id                           = module.availability_set.id
    name                         = module.availability_set.name
    fault_domain_count           = module.availability_set.platform_fault_domain_count
    update_domain_count          = module.availability_set.platform_update_domain_count
    proximity_placement_group_id = module.availability_set.proximity_placement_group_id
  }
}
