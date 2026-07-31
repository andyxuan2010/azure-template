# Linux VM Architecture

The module composes compute, networking, bootstrap, and access around existing shared services.

```text
Existing subnet ──────────────> NIC ─────────────> Linux VM
                                  │                  │
Optional public access ─> PIP + NSG                 ├─> cloud-init / init.sh
Shared IaC storage ─────────────────────────────────┼─> localization extension
Shared Key Vault ───────────────────────────────────┼─> credential/bootstrap secrets
Entra groups + Bastion (optional) ──────────────────└─> scoped RBAC
```

## Resource Multiplicity

`vm_count` controls the number of NIC and VM instances. Public IPs and NSGs are created per VM only when public networking is enabled. An optional managed data disk is also created and attached per VM.

Static private IP addresses are positional: the first address maps to VM index 0, and so on. Multi-VM deployments can distribute instances across `availability_zones` in round-robin order.

## Bootstrap Sequence

1. Terraform resolves direct credentials or Key Vault-backed fallbacks.
2. The VM starts with module-owned `scripts/init.sh` as cloud-init `custom_data`.
3. Caller `post_init_script` content runs after the base initialization.
4. Optional Entra SSH and localization extensions run after VM creation.
5. The VM identity uses assigned storage and Key Vault roles for supported runtime access.

Plan-only validation cannot prove that guest scripts, domain services, package repositories, DNS, or extension downloads will succeed. Monitor VM provisioning and extension status after apply.

## Network Boundary

The module owns NICs and optional public-access resources. It does not own the VNet, subnet, routing, DNS, firewall, VPN/ExpressRoute, or Bastion host. Private administration is the recommended default.

When public SSH is enabled, the module requires explicit trusted source prefixes. Guest firewall and organizational policy controls remain separate layers.

## Identity and RBAC Boundary

System-assigned identity is enabled by default. The module assigns roles needed by its shared storage and Key Vault workflows and can assign application groups to VM, NIC, resource-group, Bastion, and Entra login scopes.

Because these scopes have different privilege levels, review the planned role assignments for every environment and separate infrastructure administration from guest login where possible.
