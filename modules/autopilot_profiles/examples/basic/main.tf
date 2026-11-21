provider "msgraph" {}
module "autopilot_profiles" {
  source = "../../"
  resources = {
    example = {
      "@odata.type" = "#microsoft.graph.azureADWindowsAutopilotDeploymentProfile"
      displayName   = "Example Autopilot profile"
      language      = "os-default"
    }
  }
}
