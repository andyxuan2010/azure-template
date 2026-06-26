# Linux VM Authentication Guide

This document explains the two authentication models supported by the `linuxvm` module:

- traditional Active Directory domain join
- Microsoft Entra ID SSH login

These models can coexist, but they are not the same thing and they do not use the same login path.

## Authentication Modes

### 1. Active Directory Domain Join

This is the traditional enterprise model.

When `enable_domain_join = true`, the module:

- renders the domain join values into `custom_data`
- boots the VM and runs [init.sh](scripts/init.sh)
- uses managed identity plus Key Vault to retrieve the domain join secret
- installs `realmd`, `sssd`, `adcli`, and related packages
- joins the VM to the AD domain
- configures guest SSH and sudo access for the requested groups

This path is guest-OS native. The VM becomes a domain-joined Linux host.

When `enable_domain_join = false`, the module still runs the normal `init.sh` bootstrap, but the script now skips the entire AD join path cleanly without attempting Azure login, Key Vault secret retrieval, or `realm join`.

### 2. Microsoft Entra ID SSH Login

This is the Azure-native SSH model.

When `enable_entra_ssh_login = true`, the module:

- installs the `AADSSHLoginForLinux` VM extension
- adds Azure VM login RBAC for the provided groups
  - `app_admin_group` -> `Virtual Machine Administrator Login`
  - `app_user_group` -> `Virtual Machine User Login`
- keeps the existing VM resource RBAC
- `app_admin_group` -> `Contributor` on each VM resource, `Contributor` on each module-created NIC, plus `Reader` on the VM resource group
- `app_user_group` -> `Reader` on each VM resource, plus `Reader` on the VM resource group

When Bastion is configured:
- `app_admin_group` -> `Reader` on the Bastion resource group and `Network Contributor` on the Bastion host
- `app_user_group` -> `Reader` on the Bastion resource group and `Network Contributor` on the Bastion host

For the VM resource group and Bastion resource group `Reader` assignments, the module checks for existing assignments at that exact resource-group scope so consumers can import matching ones from the root module or with `terraform import` before apply. Reader assignments on child resources under the resource group do not satisfy the resource-group Reader path.

This path is Azure identity based. It does not require the VM to be domain joined.

## Time Sequence

The authentication pieces are applied in this order:

1. Terraform creates the Linux VM.
2. Terraform passes the rendered `custom_data` payload to the VM.
3. On first boot, cloud-init runs [init.sh](scripts/init.sh).
4. If `enable_domain_join = true`, the AD join steps run inside the guest.
5. Terraform installs the optional `AADSSHLoginForLinux` extension when `enable_entra_ssh_login = true`.
6. Terraform applies the Azure RBAC role assignments for VM resource access and, when enabled, Entra VM login access.

This means:

- AD authentication is established through guest configuration in `custom_data`
- Entra SSH authentication is established through the VM extension plus Azure RBAC

## Use Cases

### Use AD Domain Join When

- the VM must behave like a traditional domain-joined server
- Linux identity resolution should come from AD through `sssd`
- guest sudo access should be driven by domain groups
- existing operational tooling expects classic AD integration

### Use Entra SSH When

- the VM is not domain joined
- access should be controlled through Azure RBAC
- administrators connect from Azure CLI, Bastion, or other Entra-aware tooling
- the target operating model is cloud-native access rather than classic domain trust

### Use Both When

- you are in a migration period
- you need both classic AD behavior and Entra-based SSH access
- different teams use different access methods temporarily

Using both is valid, but it increases support and troubleshooting complexity.

## AD Login Details

For the domain-join path, the important module input is:

- `enable_domain_join = true`

Important prerequisites:

- system-assigned managed identity is enabled on the VM
- the VM can reach Azure endpoints and the domain infrastructure
- the shared Key Vault contains the domain join password
- DNS and network routing support the domain join path

Expected user experience:

- users connect with normal SSH methods supported by the guest
- authentication is resolved through the joined AD domain
- `app_admin_group` members can receive guest sudo access through the script configuration

## Entra SSH Details

For the Entra path, the important module input is:

- `enable_entra_ssh_login = true`

Important prerequisites:

- the `AADSSHLoginForLinux` extension is installed successfully
- the user or group has the right Azure RBAC assignment on the VM
- the client uses an Entra-aware SSH flow
- the VM can reach required Azure and Entra endpoints over HTTPS

### RBAC Mapping

When Entra SSH is enabled, the module adds:

- `app_admin_group` -> `Virtual Machine Administrator Login`
- `app_user_group` -> `Virtual Machine User Login`

These are guest sign-in roles.

They are different from:

- `Contributor`
- `Reader`

Those two are Azure resource management roles, not VM guest login roles.

### Group Input Guidance

For `app_admin_group` and `app_user_group`:

- group principal IDs are expected
- empty strings are ignored, so `[]`, `null`, or `[""]` skips the related group RBAC
- user object IDs are not a supported replacement for group IDs in these inputs

### Working Entra Methods

These methods are expected to work when the extension, RBAC, and networking are correct:

- `az ssh vm`
- `az ssh config` followed by `ssh`
- Azure Bastion with Microsoft Entra ID
- Azure portal SSH when the authentication type is switched to `Microsoft Entra ID`

### Methods That Are Not Expected To Work

These are common paths that should not be treated as the supported Entra SSH method:

- plain `ssh <aad-user>@<host>` with no Azure CLI-assisted Entra flow
- Azure portal SSH with `VM password` when you expect Entra credentials to work
- using `Contributor` or `Reader` alone and expecting guest login access
- assuming a synced on-prem AD password is the same as Linux local VM password authentication

### Why `VM password` Does Not Equal Entra Login

In the Azure portal, `Microsoft Entra ID` and `VM password` are different authentication paths.

`Microsoft Entra ID`:

- uses the `AADSSHLoginForLinux` extension
- uses Azure and Entra authentication
- depends on `Virtual Machine Administrator Login` or `Virtual Machine User Login`

`VM password`:

- uses the VM's local Linux account
- expects the local `admin_username` and `admin_password`
- does not use your Entra identity

In this module, the Entra extension settings also disable SSH password authentication for the Entra path. So an Entra user succeeding with `Microsoft Entra ID` and failing with `VM password` is expected behavior.

## Administrator vs User Login Roles

### `Virtual Machine User Login`

This role is for regular Entra-based sign-in to the VM.

It is intended for:

- non-admin SSH access
- basic shell access
- operations that do not require elevation

### `Virtual Machine Administrator Login`

This role is for elevated Entra-based sign-in to the VM.

It is intended for:

- administrator SSH access
- users who need elevated privileges on the VM

For Linux, this is the Azure role associated with admin-level sign-in and expected `sudo` capability after logon.

## Troubleshooting Checklist

If Entra login still fails:

1. Confirm `enable_entra_ssh_login = true`.
2. Confirm the VM extension is installed and healthy.
3. Confirm the user or group has `Virtual Machine Administrator Login` or `Virtual Machine User Login`.
4. Wait for RBAC propagation.
5. If the role is eligible through PIM, activate it.
6. Use `az ssh vm` or `az ssh config` instead of plain `ssh`.
7. Confirm port `22` access through the intended network path.
8. Confirm outbound HTTPS from the VM to Azure and Entra endpoints.
9. Check Conditional Access or MFA requirements.

If AD login fails:

1. Confirm `enable_domain_join = true`.
2. Confirm the VM has managed identity enabled.
3. Confirm Key Vault access is working.
4. Confirm DNS and domain controller reachability.
5. Review guest logs from the bootstrap phase.

## Related Docs

- [README.md](README.md)
- [INIT.md](scripts/INIT.md)
- [LOCALIZATION.md](scripts/LOCALIZATION.md)
