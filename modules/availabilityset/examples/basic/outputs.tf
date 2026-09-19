output "availability_set_id" {
  description = "Resource ID to pass to virtual-machine resources."
  value       = module.availability_set.id
}

output "availability_set_name" {
  description = "Availability Set name."
  value       = module.availability_set.name
}
