locals {
  workload_code           = lower(join("", regexall("[a-z0-9-]", trimspace(var.workload))))
  display_name            = trimspace(var.display_name) != "" ? trimspace(var.display_name) : substr("mg-${local.workload_code}-${var.app_env}-${trimspace(var.instance)}", 0, 90)
  normalized_display_name = lower(join("", regexall("[a-z0-9]", local.display_name)))
  generated_name          = trim(substr("mg-${local.normalized_display_name != "" ? local.normalized_display_name : "landingzone"}-${try(random_string.suffix[0].result, "0000")}", 0, 90), "-")
  management_group_name   = trimspace(var.name) != "" ? var.name : local.generated_name
  subscription_ids        = sort(distinct([for subscription_id in var.subscription_ids : lower(trimspace(subscription_id))]))

  merged_tags = var.tags
}
