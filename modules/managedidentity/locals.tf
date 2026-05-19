locals {
  merged_tags = merge(
    var.tags,
    {
      module = "managedidentity"
    }
  )
}
