provider "msgraph" {}
module "autopilot_device_import" {
  source = "../../"
  resources = {
    example = {
      serialNumber       = "EXAMPLE001"
      hardwareIdentifier = "BASE64_HARDWARE_HASH"
      groupTag           = "Pilot"
    }
  }
}
