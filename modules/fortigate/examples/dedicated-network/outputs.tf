output "virtual_network_id" {
  description = "Module-created VNet resource ID."
  value       = module.fortigate.virtual_network_id
}

output "subnet_ids" {
  description = "Module-created FortiGate subnet IDs."
  value       = module.fortigate.subnet_ids
}

output "virtual_machine_ids" {
  description = "FortiGate virtual machine IDs."
  value       = module.fortigate.virtual_machine_ids
}
