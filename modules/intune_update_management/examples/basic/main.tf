provider "msgraph" {}
module "intune_update_management" {
  source = "../../"
  resources = {
    example = {
      "@odata.type"                      = "#microsoft.graph.windowsUpdateForBusinessConfiguration"
      displayName                        = "Example Windows update policy"
      qualityUpdatesDeferralPeriodInDays = 7
    }
  }
}
