# Production overrides. Values here replace the matching root terraform.tfvars
# values in full (maps are not deep-merged), so fortigate_interfaces must list
# every interface.
#
# secondary_private_ip_addresses_by_suffix adds static secondary IP
# configurations (ipconfig2, ipconfig3, ...) to the NIC in the interface subnet.
# List position determines the ipconfig name: append new addresses, do not
# reorder or remove from the middle, or Terraform will recreate ipconfigs.
#
# TODO: replace the example secondary addresses with the reserved prod IPs.
fortigate_interfaces = {
  external = {
    role      = "external"
    subnet_id = ""
    primary   = true
    private_ip_addresses = {
      a = "10.42.10.4"
      b = "10.42.10.5"
    }
    secondary_private_ip_addresses_by_suffix = {
      a = ["10.42.10.10"]
      b = ["10.42.10.11"]
    }
  }
  internal = {
    role      = "internal"
    subnet_id = ""
    private_ip_addresses = {
      a = "10.42.11.4"
      b = "10.42.11.5"
    }
    secondary_private_ip_addresses_by_suffix = {
      a = ["10.42.11.10"]
      b = ["10.42.11.11"]
    }
  }
}
