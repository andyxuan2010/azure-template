provider "msgraph" {}
module "intune_baseline" {
  source = "../../"
  resources = {
    example = {
      "@odata.type" = "#microsoft.graph.windows10GeneralConfiguration"
      displayName   = "Example Windows configuration"
    }
  }
}
