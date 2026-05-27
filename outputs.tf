# -------------------------------------------------------------------
# Root Outputs
# -------------------------------------------------------------------
# Outputs are intentionally minimal for the module-plan harness.
# The old output surface depended on legacy root module names that no
# longer exist in this rebuilt sample configuration.
# -------------------------------------------------------------------

output "module_plan_enabled" {
  description = "Effective per-module plan toggle settings for the harness after applying high-level feature switches."
  value       = local.module_plan_enabled
}

output "feature_flags" {
  description = "Effective high-level feature switches."
  value       = local.feature_flags
}
