locals {
  normalized_display_name = lower(join("", regexall("[a-z0-9]", var.display_name)))
  generated_name          = trim(substr("mg-${local.normalized_display_name != "" ? local.normalized_display_name : "landingzone"}-${try(random_string.suffix[0].result, "0000")}", 0, 90), "-")
  management_group_name   = trimspace(var.name) != "" ? var.name : local.generated_name
  subscription_ids        = sort(distinct([for subscription_id in var.subscription_ids : lower(trimspace(subscription_id))]))

  merged_tags = var.tags
}
