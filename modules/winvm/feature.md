# Windows VM Module Features

This file lists implemented module features in a comparison-friendly way. It focuses on capabilities rather than the operating system itself, so it can be compared with `modules/linuxvm/feature.md`.

## Core Provisioning

- Creates one or more Azure Windows VMs with `app_vm_number`.
- Uses environment-based name suffixes for repeatable VM, NIC, public IP, NSG, and disk names.
- Supports configurable VM size.
- Supports configurable marketplace image publisher, offer, SKU, and version.
- Enables VM agent provisioning.
- Supports configurable Windows guest patch mode through `patch_mode`.
- Supports platform patch assessment when `patch_mode = "AutomaticByPlatform"`.
- Supports availability zone spread for multi-VM deployments by round-robin assignment from `availability_zones`.
- Ignores admin credential and `custom_data` drift on the VM resource to avoid forced VM replacement from bootstrap or secret changes.

## Identity And Credentials

- Enables a system-assigned managed identity on every VM.
- Grants the VM identity access to the shared IaC storage account with `Storage Blob Data Contributor`.
- Grants the VM identity access to the shared IaC Key Vault with `Key Vault Reader`.
- Grants the VM identity Key Vault secrets access with `Key Vault Secrets Officer`.
- Resolves admin username from direct `azure-user` input or Key Vault fallback.
- Resolves admin password from direct `azure-password` input or Key Vault fallback.
- Supports an optional separate Key Vault resource ID for admin and domain join secrets.
- Uses Terraform preconditions to require effective admin username and password.

## Access And RBAC

- Accepts app admin groups through `app_admin_group`.
- Accepts app user groups through `app_user_group`.
- Accepts groups as Entra object IDs or display names where lookup is supported.
- Supports extra VM login groups through `vm_admin_group` and `vm_remote_group`.
- Grants app admin groups `Contributor` on each VM resource.
- Grants app admin groups `Contributor` on each module-created NIC.
- Grants app user groups `Reader` on each VM resource.
- Grants admin login groups `Virtual Machine Administrator Login` on each VM.
- Grants user login groups `Virtual Machine User Login` on each VM.
- Supports optional Windows domain or NetBIOS prefixing for local Windows group membership with `windows_group_domain_prefix`.
- Bootstrap adds resolvable admin groups to local `Administrators`.
- Bootstrap adds resolvable user groups to local `Remote Desktop Users`.
- Supports Microsoft Entra login through the `AADLoginForWindows` extension, enabled by default.

## Networking

- Creates one NIC per VM.
- Resolves an existing VNet and subnet from `app_vnet_rg`, `app_vnet`, and `app_snet`.
- Uses dynamic private IP assignment.
- Supports optional public networking.
- When public networking is enabled, creates a static Standard public IP per VM.
- When public networking is enabled, creates an NSG per VM with inbound RDP on TCP 3389.
- Associates each public-network NSG to its VM NIC.
- Installs the Azure Network Watcher Agent extension on every VM.

## Storage And Data Disks

- Supports an optional managed data disk per VM with `disksize`.
- Skips data disk creation when `disksize = 0`.
- Places optional managed data disks in the same computed availability zone as the VM.
- Attaches optional data disks at LUN 0 with `ReadWrite` caching.
- Bootstrap initializes RAW data disks inside the guest.

## Bootstrap And Customization

- Uses `scripts/init2.ps1` as the active bootstrap script.
- Stores `init2.ps1` in VM `custom_data` as a fallback/staging payload.
- Supports bootstrap execution through `CustomScriptExtension` with `enable_custom_script_extension`.
- Supports bootstrap execution through `azurerm_virtual_machine_run_command` with `enable_virtual_machine_run_command`.
- Enforces Custom Script Extension and Run Command as mutually exclusive execution paths.
- Prefers Run Command for update/rerun behavior because script content is embedded in the Run Command source.
- Passes environment, group, storage account, localization container, tenant ID, SHIR, Defender performance mode, and reboot arguments to bootstrap.
- Registers a `post-cloud-init` scheduled task for deferred idle-time package installation.
- Scheduled task runs as SYSTEM after boot delay and idle conditions.
- Scheduled task defers when logged-on user sessions are detected.
- Supports optional consumer-owned localization scripts from the shared storage account.
- Localization supports common scripts named `localization.ps1` or `windows-localization.ps1`.
- Localization supports VM-specific scripts named `<COMPUTERNAME>.ps1` or `<VM_NAME>.ps1`.
- Stages optional `validation.ps1` when available in storage.
- Downloads module-owned assets such as `scheduled.ps1`, `default.bgi`, and `bbd.png` from the scripts container.

## Domain Join

- Supports optional traditional Active Directory domain join through `enable_domain_join`.
- Domain join is performed by Azure `JsonADDomainExtension`.
- Domain join is skipped in the `sbx` environment.
- Domain join is mutually exclusive with `AADLoginForWindows`.
- Resolves domain join username from direct input or Key Vault fallback.
- Resolves domain join password from direct input or Key Vault fallback.
- Uses protected extension settings for the domain join password.
- Includes `scripts/domain-join.ps1` as a manual repair/testing helper that can use managed identity and Key Vault REST APIs.

## Guest Baseline And Tooling

- Sets Windows time zone, defaulting to `Eastern Standard Time`.
- Enables ICMP firewall access.
- Configures OpenSSH Server, firewall rule, and administrator authorized keys.
- Configures WinRM securely by default.
- Supports opt-in insecure WinRM behavior inside the script, but the module does not currently pass that switch.
- Cleans Azure Arc surfacing.
- Supports optional temporary Defender performance mode during heavy install phases.
- Installs baseline tools during initial bootstrap: PowerShell 7, Azure CLI, 7-Zip, and standalone BGInfo.
- Optionally installs/registers Self-hosted Integration Runtime when `enable_shir = true`.
- Defers larger tool installs to `scheduled.ps1`: Az modules, AWS CLI, Git, Terraform, Sysinternals Suite, Postman, MobaXterm, and AzCopy.
- Updates PATH after tool installation.
- Configures BGInfo and BBD wallpaper.
- Registers BGInfo startup/logon behavior.
- Writes bootstrap logs to `C:\ProgramData\Logs\Init\InitLog.txt`.

## Optional SHIR And Data Factory

- Supports Self-hosted Integration Runtime bootstrap with `enable_shir`.
- Requires a bootstrap execution method when SHIR is enabled.
- Requires `adf_id` when SHIR is enabled.
- Grants VM identity `Data Factory Contributor` on the configured Azure Data Factory when SHIR is enabled.
- Reads SHIR registration key through the bootstrap flow.
- Writes a local SHIR registration marker to avoid repeated registration.

## Diagnostics And Validation

- Exposes `enable_diagnostics` and `log_analytics_workspace_id` inputs with validation.
- Outputs whether diagnostics were enabled.
- Does not currently create an `azurerm_monitor_diagnostic_setting`; `diagnostics.tf` documents that this was intentionally omitted for provider schema compatibility.
- Includes a VM-side `validation.ps1` helper.
- Includes a Terraform test file at `tests/live.tftest.hcl`.

## Outputs

- Outputs private IPs, optional public IP, VM IDs, managed identity principal IDs, effective tags, diagnostics flag, and role assignment IDs.

## Comparison Notes

- Closest Linux equivalent for Windows Run Command or Custom Script bootstrap is Linux `custom_data` plus optional CustomScript localization extension.
- Windows has no inline `post_init_script` input equivalent.
- Windows has optional SHIR and Data Factory RBAC; Linux does not currently expose an equivalent.
- Windows has Network Watcher Agent extension enabled by default; Linux does not currently create the Linux Network Watcher extension.
- Windows has a diagnostics flag but no diagnostic setting resource; Linux does not expose diagnostics inputs.
- Windows consumes localization blobs from storage but does not upload VM-specific localization content from a module input.
- Windows Entra login uses `AADLoginForWindows`; Linux Entra login uses `AADSSHLoginForLinux`.
- Windows AD join uses `JsonADDomainExtension`; Linux AD join happens in guest bootstrap with `realm`.
- Windows public access opens RDP; Linux public access opens SSH.
- Windows does not currently expose Spot VM settings; Linux does.

## Common Features In Both Modules

- Multi-VM deployment support.
- Environment-based suffixing for VM and related resource names.
- Configurable VM size.
- Configurable marketplace image publisher, offer, SKU, and version.
- Availability zone spread for multi-VM deployments.
- System-assigned managed identity.
- Shared IaC storage account access for the VM identity.
- Shared IaC Key Vault access for the VM identity.
- Admin credential resolution from direct inputs or Key Vault secrets.
- Terraform validation or preconditions for required inputs.
- App admin and app user group inputs.
- VM-level RBAC for admin and user access patterns.
- NIC-level Contributor RBAC for admin groups.
- Microsoft Entra VM login support through OS-specific extensions.
- Optional traditional Active Directory domain join.
- Optional public networking with static Standard public IPs and NSGs.
- One NIC per VM with dynamic private IP assignment.
- Optional managed data disk per VM.
- Data disk zone alignment with VM zone placement.
- First-boot or post-provision bootstrap scripting.
- Storage-backed localization or customization path.
- Guest-side operational tooling installation.
- Effective tag merging with inherited resource group tags and custom tags.
- Terraform test file under each module's `tests` directory.
- Outputs for VM IDs, private IPs, managed identity principal IDs, role assignment IDs, and tags.

## Differences And Gaps

| Capability | Linux VM module | Windows VM module | Gap or equivalent |
|---|---|---|---|
| VM count input | `vm_count` | `app_vm_number` | Same capability, different input name. |
| Resource group/subnet inputs | Uses `resource_group_name` and direct `subnet_id` | Uses `app_rg`, `app_vnet_rg`, `app_vnet`, and `app_snet` lookups | Linux uses direct subnet ID; Windows resolves subnet by names. |
| Managed identity toggle | Optional with `enable_system_assigned_identity` | Always enabled | Windows has no disable switch. |
| Spot VM | Supported with `enable_spot_instance` | Not exposed | Missing on Windows side if Spot is desired. |
| Boot diagnostics | Explicit `boot_diagnostics {}` block | No explicit boot diagnostics block | Missing explicit Windows equivalent. |
| Patch settings | `patch_assessment_mode = "AutomaticByPlatform"` | Configurable `patch_mode` and derived assessment mode | Windows has more patch-mode control. |
| Public inbound rule | SSH TCP 22 | RDP TCP 3389 | Same public access pattern, OS-specific port. |
| Entra login | Optional `AADSSHLoginForLinux` | `AADLoginForWindows`, enabled by default | Same intent, different extension and default. |
| AD domain join | Guest bootstrap with `realm join` | `JsonADDomainExtension` | Same intent, different implementation. |
| Domain join password input | Key Vault secret only in active path | Direct input or Key Vault fallback | Linux lacks direct password override. |
| Bootstrap execution | VM `custom_data` cloud-init | Custom Script Extension or VM Run Command | Windows has explicit execution-method switches. |
| Inline post-bootstrap script | `post_init_script` input | Not exposed | Missing on Windows side. |
| Localization upload | Can upload VM-specific blobs from Terraform input | Consumes existing storage blobs only | Missing Windows module-managed upload. |
| Localization rerun trigger | Content-derived extension timestamp | Run Command can rerun when bootstrap changes; scheduled localization is storage-driven | Not a one-to-one equivalent. |
| Deferred idle installs | Not implemented as scheduled idle task | Implemented with `post-cloud-init` scheduled task | Windows-only behavior. |
| Network Watcher Agent | Not created | Created on every VM | Missing on Linux side if required. |
| Diagnostics inputs | Not exposed | Exposes diagnostics flag/workspace but no diagnostic setting resource | Windows has partial diagnostics interface. |
| SHIR / Data Factory | Not exposed | Optional SHIR bootstrap and ADF RBAC | Windows-only feature. |
| Guest local group handling | Sudo and SSH access during AD join path | Local Administrators and Remote Desktop Users membership | Equivalent intent, OS-specific implementation. |
| Tooling scope | Broad cloud/devops/Kubernetes/container tooling installed in bootstrap | Baseline tooling first, larger tools deferred to scheduled task | Both install tooling; sequencing differs. |
| OpenSSH | Native Linux SSH hardening | Configures Windows OpenSSH Server | Equivalent remote shell capability, OS-specific setup. |
| Validation helper | Terraform test only | Terraform test plus VM-side `validation.ps1` | Windows has extra guest validation script. |
