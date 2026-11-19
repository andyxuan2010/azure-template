provider "azuread" {}
module "device_groups" {
  source = "../../"
  groups = {
    autopilot_devices = {
      display_name    = "Intune - Autopilot devices"
      description     = "Device targeting group for Autopilot assignments."
      membership_rule = "(device.devicePhysicalIDs -any (_ -startsWith \"[ZTDId]\"))"
    }
  }
}
