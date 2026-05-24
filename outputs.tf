# -------------------------------------------------------------------
# Root Outputs
# -------------------------------------------------------------------
# Outputs are intentionally minimal for the module-plan harness.
# The old output surface depended on legacy root module names that no
# longer exist in this rebuilt sample configuration.
# -------------------------------------------------------------------

output "module_plan_enabled" {
  description = "Current per-module plan toggle settings for the harness."
  value       = var.module_plan_enabled
}
