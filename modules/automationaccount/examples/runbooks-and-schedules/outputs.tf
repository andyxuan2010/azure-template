output "runbook_names" {
  description = "Runbook names keyed by logical name."
  value       = module.scheduled_automation.runbook_names
}

output "schedule_names" {
  description = "Schedule names keyed by logical name."
  value       = module.scheduled_automation.schedule_names
}

output "job_schedule_ids" {
  description = "Job schedule resource IDs keyed by logical name."
  value       = module.scheduled_automation.job_schedule_ids
}
