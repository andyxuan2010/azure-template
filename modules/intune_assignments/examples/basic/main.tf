provider "msgraph" {}
module "intune_assignments" {
  source = "../../"
  resources = {
    baseline = {
      resource_url = "deviceManagement/deviceConfigurations/00000000-0000-0000-0000-000000000000"
      body = {
        deviceAndAppManagementAssignmentFilterType = "none"
        target = {
          "@odata.type" = "#microsoft.graph.allDevicesAssignmentTarget"
        }
      }
    }
  }
}
