# Linux VM Operational Overview

This document captures a practical Linux VM deployment view for the `linuxvm` module: features, security posture, access model, networking, bootstrap flow, installed package patterns, and a recommended improvement backlog.

It is intended as an operations-oriented companion to the module reference docs such as `README.md`, `AUTHENTICATION.md`, `scripts/INIT.md`, and `scripts/LOCALIZATION.md`.

## What The Module Supports

- Azure Linux VM creation with environment-based hostname suffixing
- NIC creation and optional public IP / NSG creation
- optional extra managed data disk
- shared-tag model through optional resource group tag inheritance, input `tags`, and module-generated `workload`
- bootstrap via `custom_data` using the module-owned `scripts/init.sh`
- optional inline `post_init_script` appended after `init.sh`
- optional storage-backed Linux VM localization through a `CustomScript` extension
- optional Terraform-managed upload of hostname-specific localization blobs to the shared IaC storage account
- optional Microsoft Entra SSH login through `AADSSHLoginForLinux`
- optional traditional AD domain join during bootstrap
- optional system-assigned managed identity
- Azure RBAC assignment for VM admin and VM user groups
- storage and Key Vault role assignments for the VM managed identity

## Bootstrap Sequence

The module currently supports three bootstrap places:

1. `custom_data` bootstrap via `scripts/init.sh`
2. optional `post_init_script`
3. optional merged localization script delivered through the localization VM extension

Behavior:

- `init.sh` is rendered by Terraform and sent as the base `custom_data` payload.
- `init.sh` now mirrors its output into `/var/log/localization/init.log` with UTC timestamps while still flowing into the default cloud-init logs.
- If `post_init_script` is non-empty, it is appended to the generated bootstrap payload.
- The appended post-init content is staged as `/opt/bootstrap/post-init.sh` and executed after the base `init.sh` logic completes.
- If `enable_linux_vm_extension = true`, the localization extension runs later as a separate post-bootstrap phase.
- The localization extension best-effort downloads an OS-level script such as `ubuntu.sh`, then optionally merges a VM-specific script such as `myvm001.sh` into one merged localization script.
- If either localization blob is missing, unreachable, or empty, that script is skipped without failing the extension.
- Consumers can optionally have Terraform upload hostname-specific localization blobs by passing `localization_vm_script_content`, which updates the remote blob when the local script content changes.
- When `localization_vm_script_content` is provided, Terraform orders those managed VM-specific blob uploads before the localization extension resource.
- Managed VM-specific blob-content changes are also folded into the extension `timestamp` setting so the extension can rerun against the updated blob content.
- When `data_disk_size_gb > 0`, Terraform also orders the localization extension after the VM data-disk attachment resource so guest-side disk initialization scripts can see the attached disk.
- Terraform can also place the localization extension after optional Entra SSH extension resources when those are enabled, but that ordering is only a graph convenience.
- The localization runner now handles storage-backed script downloads inside the guest and skips cleanly when no localization content is available.

Package manager guidance:

- Use `init.sh` for shared package installs and core OS bootstrap.
- Use `post_init_script` for additional first-boot work that still belongs in the same bootstrap flow.
- Do not rely on the merged localization script for `apt-get`, `dnf`, or other package installation work unless there is a very deliberate reason to do so.
- Package installation in the merged localization script is not recommended because it can conflict with package-manager activity started by `init.sh` or `post_init_script`.
- A valid consumer-repo pattern is to install an application in `post_init_script` and then use the later localization phase for storage work such as data-disk preparation, application-data migration, and final mount-path activation.
- When consumers intentionally install first and mount later, the VM-specific localization script should stop the application if it is running, copy existing data to the managed disk, mount the managed disk at the final application path, and restart the service only if it was active before migration.

## Security Model

### Identity And Secrets

- The module supports a system-assigned managed identity and enables it by default.
- The VM can receive `Storage Blob Data Contributor` on the shared IaC storage account.
- When localization is enabled, the VM can also receive `Storage Blob Data Reader` for localization script access.
- The VM can receive `Key Vault Reader` and `Key Vault Secrets User` on the shared IaC Key Vault.
- VM admin username, password, and SSH public key are supplied directly through module input variables.

### Guest Access

- The module supports Microsoft Entra SSH login through the `AADSSHLoginForLinux` extension.
- The VM resource injects the SSH public key supplied through `admin_ssh_key`.
- The current module implementation still sets `disable_password_authentication = false`, so the guest is not SSH-key-only by default.
- Traditional AD join is optional and controlled by `enable_domain_join`.

### Network Posture

- The module supports private-only deployment.
- When `public_network_enabled = false`, no public IPs or SSH NSGs are created.
- When `public_network_enabled = true`, the module can create public IPs and NSGs to allow SSH.

## Access Model

### Guest OS Access

- `app_user_group` is intended for standard SSH/user access.
- `app_admin_group` is intended for SSH plus sudo/admin access.

### Azure RBAC

- `app_user_group` gets `Reader` on each VM resource.
- `app_admin_group` gets `Contributor` on each VM resource and each module-created NIC.
- When `vm_count > 1`, the module spreads VMs across availability zones by default in round-robin order unless `enable_zone_spread` is disabled.

When `enable_entra_ssh_login = true`, the module also assigns:

- `Virtual Machine User Login` for `app_user_group`
- `Virtual Machine Administrator Login` for `app_admin_group`

## Package And Tooling Baseline

The base `init.sh` script installs and configures a broad Linux administration and platform baseline. See `scripts/INIT.md` for detail.

High-level categories include:

- IaC and DevOps tooling such as Terraform CLI, Ansible, Git, Azure CLI, Azure DevOps CLI, Bicep, AzCopy, `jq`, and `yq`
- PowerShell and .NET packages
- container and platform tools such as Docker, Podman, `kubectl`, `helm`, `eksctl`, and `oc`
- packaging, build, networking, troubleshooting, and shell utilities
- low-risk SSH and sysctl hardening
- optional AD join preparation

The optional localization phase is intended for image-family and workload-specific customization layered after the base bootstrap.

## Localization Extension

The localization extension is meant for scripts stored in the shared IaC storage account.

Key inputs:

- `enable_linux_vm_extension`
- `enable_system_assigned_identity`
- `localization_container_name`
- `localization_os_script_name`
- `localization_vm_script_content`

Expected storage layout:

- OS-level script: for example `localization/ubuntu.sh`
- VM-specific script: for example `localization/myvm001.sh`

Notes:

- `localization_vm_script_content` only manages VM-specific blobs that the consumer explicitly passes to the module.
- The module does not upload or modify the shared OS-level script such as `ubuntu.sh`.
- The localization container lookup only happens when the localization extension is enabled or when at least one VM-specific blob upload is requested.
- Consumer repos may also use the localization phase for storage migration logic after a workload was already installed earlier in `init.sh` or `post_init_script`.

Artifacts created on the VM can include:

- downloaded OS script under `/var/lib/waagent/custom-script/download/0/`
- VM-specific script under `/opt/localization/`
- merged execution script at `/opt/localization/merged-localization.sh`

For detailed behavior, see `scripts/LOCALIZATION.md`.

## Logging

Module/runtime logging paths include:

- `init.sh` dedicated log: `/var/log/localization/init.log`
- cloud-init logs for the same bootstrap run: `/var/log/cloud-init-output.log` and `/var/log/cloud-init.log`
- localization runner log: `/var/log/localization/localization-<vm-hostname>.log`
- post-init staging path: `/opt/bootstrap/post-init.sh`
- merged localization script path: `/opt/localization/merged-localization.sh`

Consumer repositories may choose different logging conventions inside their own OS-level or VM-specific localization scripts.

## Versions And Pinning Notes

- The published source example commonly uses `?ref=main`, which is convenient but not ideal for reproducibility.
- Image selection inputs allow explicit pinning for publisher, offer, SKU, and version.
- Using `latest` for the image version improves freshness but reduces repeatability.

## Network Information To Document In Consumer Repos

For each real deployment, the consuming repo should document:

- target resource group
- VNet resource group
- VNet name
- subnet name
- whether public networking is enabled
- shared IaC Key Vault and storage account names
- localization container name, if used

## Operational Checklist

- Confirm the target subnet exists and has required outbound reachability.
- Confirm the shared IaC storage account and Key Vault exist.
- Confirm the VM has a managed identity when localization or Key Vault-backed bootstrap is required.
- Confirm the required Entra groups are correct for user/admin access.
- Confirm the image family matches the localization script, for example `ubuntu.sh` vs `rhel.sh`.
- Confirm storage firewall and private networking rules allow the VM to reach the localization blobs when enabled.

## Recommended Improvements

- Pin module consumers to a release tag or commit SHA instead of `main`.
- Pin tested OS image versions instead of always using `latest`.
- Revisit `disable_password_authentication = false` if SSH password login is not required.
- Add a standard Entra SSH runbook for private-network access.
- Add package/version pinning guidance for workload-specific localization scripts.
- Add post-deployment health validation for installed services.
- Add a standard backup and recovery note for the VM and attached disk.
- Add clearer private endpoint and storage firewall guidance for localization flows.
- Keep the Terraform `localization-runner.sh.tftpl` escaping validated so Bash variables render safely through `templatefile()`.
