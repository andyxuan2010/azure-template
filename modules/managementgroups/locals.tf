locals {
  normalized_display_name = lower(join("", regexall("[a-z0-9]", var.display_name)))
  generated_name          = substr("mg-${local.normalized_display_name != "" ? local.normalized_display_name : "landingzone"}-${random_string.suffix.result}", 0, 90)
  management_group_name   = trimspace(var.name) != "" ? var.name : local.generated_name

  merged_tags = var.tags
}
