# Linux VM Module Features

This file lists implemented module features in a comparison-friendly way. It focuses on capabilities rather than the operating system itself, so it can be compared with `modules/winvm/feature.md`.

## Core Provisioning

- Creates one or more Azure Linux VMs with `vm_count`.
- Uses environment-based name suffixes for repeatable VM, NIC, public IP, NSG, and disk names.
- Supports configurable VM size.
- Supports configurable marketplace image publisher, offer, SKU, and version.
- Enables managed boot diagnostics through the VM `boot_diagnostics {}` block.
- Enables VM agent provisioning.
- Supports platform patch assessment with `AutomaticByPlatform`.
- Supports optional Azure Spot VM mode with configurable eviction policy and max bid price.
- Supports availability zone spread for multi-VM deployments by round-robin assignment from `availability_zones`.

## Identity And Credentials

- Supports system-assigned managed identity, enabled by default and optionally disabled.
- Grants the VM identity access to the shared IaC storage account with `Storage Blob Data Contributor`.
- Grants the VM identity access to the shared IaC Key Vault with `Key Vault Reader` and `Key Vault Secrets User`.
- Resolves admin username from direct input, then Key Vault fallback, then module default.
- Resolves admin password from direct input or Key Vault fallback when password authentication is enabled.
- Resolves admin SSH public key from direct input or Key Vault fallback.
- Supports disabling password authentication for SSH-key-only access.
- Uses Terraform preconditions to require effective admin username, password where needed, and SSH key.

## Access And RBAC

- Accepts app admin group principal IDs through `app_admin_group`.
- Accepts app user group principal IDs through `app_user_group`.
- Grants app admin groups `Contributor` on each VM resource.
- Grants app admin groups `Contributor` on each module-created NIC.
- Grants app user groups `Reader` on each VM resource.
- Supports optional Microsoft Entra SSH login through the `AADSSHLoginForLinux` extension.
- When Entra SSH login is enabled, grants app admin groups `Virtual Machine Administrator Login`.
- When Entra SSH login is enabled, grants app user groups `Virtual Machine User Login`.
- During AD join bootstrap, grants configured admin groups passwordless sudo inside the guest.

## Networking

- Creates one NIC per VM.
- Attaches NICs to an existing subnet by subnet resource ID.
- Uses dynamic private IP assignment.
- Supports optional public networking.
- When public networking is enabled, creates a static Standard public IP per VM.
- When public networking is enabled, creates an NSG per VM with inbound SSH on TCP 22.
- Associates each public-network NSG to its VM NIC.

## Storage And Data Disks

- Supports an optional managed data disk per VM with `data_disk_size_gb`.
- Skips data disk creation when `data_disk_size_gb = 0`.
- Places optional managed data disks in the same computed availability zone as the VM.
- Attaches optional data disks at LUN 0 with `ReadWrite` caching.

## Bootstrap And Customization

- Renders `scripts/init.sh` through Terraform `templatefile`.
- Sends the rendered bootstrap through VM `custom_data`.
- Supports `post_init_script`, appended after the module-owned `init.sh` in the same first-boot flow.
- Supports an optional storage-backed localization CustomScript extension through `enable_linux_vm_extension`.
- Localization extension uses managed identity to access storage.
- Supports an OS-level localization script from the shared localization container.
- Supports VM-specific localization scripts named by hostname.
- Supports Terraform-managed upload of VM-specific localization script content through `localization_vm_script_content`.
- Uses content-derived extension timestamps so VM-specific localization script changes can cause extension reruns.
- Orders localization after optional data disk attachment.
- Requires system-assigned identity when the localization extension is enabled.

## Domain Join

- Supports optional traditional Active Directory domain join through `enable_domain_join`.
- Domain join is performed inside `scripts/init.sh` with `realm join`.
- Resolves domain join username from direct `domain_join_user` input or Key Vault secret fallback.
- Reads domain join password from the shared Key Vault secret `domain-join-password`.
- Uses managed identity and Azure CLI inside the guest to retrieve the domain join password.
- Skips all domain join work when domain join inputs are empty or the feature is disabled.
- Installs or attempts to install AD join packages such as `realmd`, `sssd`, `adcli`, Kerberos, and related tools.

## Guest Baseline And Tooling

- Detects package manager across `apt-get`, `dnf`, and `yum`.
- Applies baseline SSH settings such as keepalive, disabled root login, disabled X11 forwarding, max auth tries, and login grace time.
- Applies shell/session defaults such as `umask`, history sizing, and idle timeout.
- Applies selected sysctl network hardening settings.
- Configures time zone.
- Enables time sync and audit services when available.
- Installs common operations and troubleshooting packages.
- Installs or attempts to install Azure CLI, Azure DevOps CLI extension, Bicep, Terraform, AzCopy, yq, ARM TTK, AWS CLI, kubectl, helm, eksctl, OpenShift `oc`, Docker, Docker Compose, Podman, PowerShell, .NET, Ansible, Git, GitHub CLI, and diagnostics/networking utilities.
- Adds shell aliases and completions for common tools.
- Logs bootstrap output to `/var/log/localization/init.log` while preserving cloud-init output.

## Outputs And Validation

- Outputs VM IDs, names, computer names, private IPs, private IPs by VM name, optional public IPs, NIC IDs/names, managed identity principal IDs, managed disk IDs, role assignment IDs, extension IDs, NSG IDs/names, and effective tags.
- Includes a Terraform test file at `tests/live.tftest.hcl`.

## Comparison Notes

- Closest Windows equivalent for `post_init_script` and localization is Windows bootstrap plus scheduled localization, but Linux has direct inline `post_init_script`; Windows does not currently expose an equivalent inline post-bootstrap script input.
- Linux has optional Spot VM support; Windows does not currently expose Spot settings.
- Linux has optional system-assigned identity; Windows always enables system-assigned identity.
- Linux public access opens SSH; Windows public access opens RDP.
- Linux Entra login uses `AADSSHLoginForLinux`; Windows Entra login uses `AADLoginForWindows`.
- Linux AD join happens in guest bootstrap with `realm`; Windows AD join uses Azure `JsonADDomainExtension`.
- Linux can upload VM-specific localization blobs from Terraform; Windows currently consumes localization blobs from storage but does not upload them from module input.

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
