# FortiGate Module Examples

See the module [README](README.md) for complete single, active-passive, and
module-created subnet examples.

The complete examples require the caller to provide an administrator secret
and existing subnet IDs (or enable module-created subnets). No public frontend
or inbound NSG rule is enabled by default.

## Private External Load Balancer

```hcl
external_load_balancer = {
  enabled             = true
  interface_name      = "external"
  create_public_ip    = false
  frontend_ip_address = "10.20.0.10"
}
```

## Public External Frontend

Public ingress is opt-in and does not expose FortiGate management interfaces:

```hcl
external_load_balancer = {
  enabled          = true
  interface_name   = "external"
  create_public_ip = true
  public_ip_name   = "pip-fgt-hub-prod"
}
```

Use approved NSG and FortiOS policies to limit published traffic. Keep
management on a private management interface.

NSG rules are validated for Azure-supported priorities, directions, actions,
protocols, and mutually exclusive singular/plural address and port fields.
HTTP or HTTPS load-balancer probes require a request path.

## PAYG Image

The exact Marketplace values can change. Confirm the current URN before use:

```hcl
license_type = "payg"

image = {
  publisher = "fortinet"
  offer     = "fortinet_fortigate-vm_v5"
  sku       = "<confirmed-payg-sku>"
  version   = "<pinned-version>"
}

marketplace_plan = {
  name      = "<confirmed-payg-plan>"
  product   = "fortinet_fortigate-vm_v5"
  publisher = "fortinet"
}
```

## Test Coverage

`tests/module.tftest.hcl` uses a mock Azure provider and covers single and
active-passive deployments, private and public load-balancer frontends,
module-created networking, and invalid NSG/load-balancer input rejection.
