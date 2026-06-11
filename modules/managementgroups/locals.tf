locals {
  environment_tag_map = {
    prod = "PROD"
    dev  = "DEV"
    qa   = "QA"
    test = "TEST"
    sbx  = "SBX"
    poc  = "POC"
  }

  normalized_display_name = lower(join("", regexall("[a-z0-9]", var.display_name)))
  generated_name          = substr("mg-${local.normalized_display_name != "" ? local.normalized_display_name : "landingzone"}-${random_string.suffix.result}", 0, 90)
  management_group_name   = trimspace(var.name) != "" ? var.name : local.generated_name

  mandatory_tags = {
    Environment = lookup(local.environment_tag_map, lower(trimspace(var.app_env)), upper(trimspace(var.app_env)))
    Workload    = trimspace(var.workload)
  }

  merged_tags = merge(
    var.tags,
    local.mandatory_tags,
  )
}
