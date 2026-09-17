# Windows VM Architecture

## Purpose

The `winvm` module provisions Azure Windows virtual machines for platform and application workloads. It assumes the application resource group, VNet, subnet, shared IaC Key Vault, and shared IaC storage account already exist.

## Resource Model

The module creates:

- `azurerm_windows_virtual_machine.this`: one VM per `app_vm_number`.
- `azurerm_network_interface.this`: one NIC per VM.
- `azurerm_managed_disk.this`: optional managed data disk when `disksize > 0`.
- `azurerm_virtual_machine_data_disk_attachment.this`: optional data disk attachment.
- `azurerm_public_ip.this`: optional public IP when `public_network_enabled = true`.
- `azurerm_network_security_group.this`: optional NSG with RDP rule when public networking is enabled.
- `azurerm_network_interface_security_group_association.this`: optional NIC/NSG association.
- `azurerm_virtual_machine_extension.NetworkWatcherAgentWindows`: Network Watcher agent.
- `azurerm_virtual_machine_extension.domain_join_ext`: optional JsonADDomainExtension.
- `azurerm_virtual_machine_extension.aad_login`: optional AAD login extension.
- `azurerm_virtual_machine_extension.CustomScriptInit`: optional bootstrap path.
- `azurerm_virtual_machine_run_command.Init`: optional bootstrap path.
- Multiple `azurerm_role_assignment` resources for VM login, VM/NIC RBAC, storage, Key Vault, and optional ADF access.

## Naming

The VM name and computer name are built from `app_vm` plus an environment suffix. Suffixes are defined in `main.tf`:

| Environment | Base Suffix |
|---|---:|
| `prod` | `001` |
| `staging` | `201` |
| `qa` | `301` |
| `dev` | `601` |
| `poc` | `701` |
| `test` | `801` |
| `sbx` | `901` |

For multiple VMs, suffixes increment from the environment base.

## Network Flow

The module reads the existing VNet and subnet using `data.azurerm_virtual_network.app` and `data.azurerm_subnet.app`. NICs are created with dynamic private IPs. Public IP and NSG resources are created only when `public_network_enabled = true`.

Public networking adds an inbound TCP/3389 rule only from the explicit values in `rdp_source_address_prefixes`. In normal private operations, prefer private access paths such as Bastion, VPN, or ExpressRoute instead of enabling public networking.

## Identity And RBAC

Each VM has a system-assigned managed identity. The identity receives:

- `Storage Blob Data Contributor` on the shared IaC storage account.
- `Key Vault Reader` on the effective Key Vault.
- `Key Vault Secrets Officer` on the effective Key Vault.
- Optional `Data Factory Contributor` on `adf_id` when `enable_shir = true`.

Application groups receive:

- `Virtual Machine Administrator Login` or `Virtual Machine User Login`.
- VM/NIC `Contributor` for admin groups.
- VM `Reader` for user groups.

Group values may be Entra object IDs or display names. Object IDs are preferred. GUID inputs are resolved to display names before local Windows group membership.

## Credentials

Admin credentials are resolved in this order:

1. Direct inputs `azure-user` and `azure-password`.
2. Key Vault secrets named by `admin_username_secret_name` and `admin_password_secret_name`.

The `JsonADDomainExtension` path retains its existing direct-input/Key Vault credential pattern.
The explicit `init2.ps1` path does not accept a password input: it reads the password from
`DomainJoinVaultName` and `DomainJoinPasswordSecretName`, defaulting to
`kv-ccoe-cc-nonprod` and `domain-join-password`.

The effective Key Vault is:

1. `admin_credentials_key_vault_id` when provided.
2. The shared IaC Key Vault derived from `iac_rg` and `iac_kv`.

## Bootstrap Design

Two bootstrap mechanisms are supported and mutually exclusive:

- Custom Script Extension.
- VM Run Command.

The active script is `scripts/init2.ps1`. The Run Command wrapper must remain base64 based. It writes `init2.ps1` to disk with `[System.IO.File]::WriteAllBytes` and passes arguments through a JSON array to avoid quoting and nested here-string issues.

`custom_data` is ignored for drift on the VM resource to prevent script changes from rebuilding existing VMs.

Bootstrap assets and consumer localization use separate storage containers:

- `scripts`: module/bootstrap-owned assets such as BGInfo files, `scheduled.ps1`, `validation.ps1`, and optional public key files.
- `localization_container_name`: consumer-owned scripts, defaulting to `localization`, for `localization.ps1`, optional `windows-localization.ps1`, and VM-specific `<COMPUTERNAME>.ps1` or `<VM_NAME>.ps1`.

## Domain Join

Domain join supports two mutually exclusive execution paths:

- `JsonADDomainExtension` remains available when `enable_domain_join = true`.
- When `enable_domain_join = true`, the module ignores `init2_enable_domain_join` and all four
  `init2_*` domain-join inputs; `JsonADDomainExtension` owns the join.
- When `enable_domain_join = false`, `init2_enable_domain_join` can enable an explicit join
  through a selected domain controller. The module validates all four `init2_*` inputs before
  provisioning, and `init2.ps1` validates the current domain state, DNS/SRV discovery, and
  required TCP connectivity before calling `Add-Computer -Server`. When the VM is still in a
  workgroup, it first searches the selected domain controller for a computer account matching
  the VM name and removes that stale account before calling `Add-Computer -Server`. The join
  credential therefore needs permission to delete a matching computer object. If the switch is
  disabled, the script path skips the join.

`primary_dns_suffix` is optional. When a bootstrap execution method is active, the module passes
the value to `init2.ps1`, which applies it after either the `JsonADDomainExtension` join or the
explicit `init2` join. An empty value is omitted and leaves the existing Windows suffix unchanged.
If bootstrap is disabled, the module retains its dedicated suffix Run Command fallback.

The module exposes `init2_enable_domain_join`, `init2_domain_name`, `init2_domain_controller`,
`init2_domain_join_vault_name`, and `init2_domain_join_password_secret_name` for this path. The
four `init2_*` values are required as a group only when the `init2` path is active.

If both switches are set, the module still gives `JsonADDomainExtension` authority: the
`init2.ps1` switch and all four `init2_*` inputs are not passed to the guest script.

The extension runs when `enable_domain_join = true` and `app_env != "sbx"`. It is mutually exclusive with `AADLoginForWindows`. Domain join credentials are read from direct inputs or Key Vault.

Local Windows group membership in `init2.ps1` may depend on domain resolution if values are domain-qualified names.

## SHIR

When `enable_shir = true`:

- `adf_id` must be set.
- One bootstrap execution method must be enabled.
- The VM identity receives `Data Factory Contributor` on `adf_id`.
- `init2.ps1` installs/registers Self-hosted Integration Runtime using a Key Vault secret read through managed-identity REST.

## Diagnostics

When diagnostics are enabled, the module creates one `azurerm_monitor_diagnostic_setting` per VM targeting the supplied Log Analytics workspace. The caller owns the workspace, retention model, alerting, and guest-level monitoring configuration.

## Important Constraints

- Do not enable `enable_custom_script_extension` and `enable_virtual_machine_run_command` at the same time.
- Do not enable `AADLoginForWindows` and `enable_domain_join` at the same time.
- Keep the Run Command base64 wrapper.
- Existing VM `custom_data` drift is ignored by design.
