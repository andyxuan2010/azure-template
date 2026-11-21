output "group_ids" {
  description = "Entra group object IDs keyed by caller-supplied group key."
  value       = { for key, group in azuread_group.this : key => group.object_id }
}
