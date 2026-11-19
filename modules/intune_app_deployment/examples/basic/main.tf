provider "msgraph" {}
module "intune_app_deployment" {
  source = "../../"
  resources = {
    example = {
      "@odata.type" = "#microsoft.graph.iosStoreApp"
      displayName   = "Example app"
      publisher     = "Example publisher"
      appStoreUrl   = "https://apps.apple.com/app/id000000000"
    }
  }
}
