# NSG Association Ownership Example

Creates an NSG and uses stable map keys to associate one existing subnet and one existing network interface. No custom rules are added, so Azure default NSG rules remain.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var-file="environment.tfvars"
```

Use this pattern only when this state exclusively owns both associations. A subnet or NIC cannot be simultaneously associated with another NSG by another module.

## Cost and risk

- Cost: the network security group and the subnet and NIC associations are not billed. Any flow logs or diagnostics you add elsewhere are billed separately; this example creates none.
- Risk: associating replaces any NSG already bound to that subnet or NIC, because each can have only one. The NSG has no custom rules, so only Azure default rules apply (VNet traffic, load balancer probes and outbound internet are allowed; other inbound is denied). Attaching it can change effective traffic on the subnet immediately.
- Risk: destroying the NSG or removing a key from `subnet_associations` or `network_interface_associations` unbinds that resource. Keep the keys stable and do not manage the same association from another module.
