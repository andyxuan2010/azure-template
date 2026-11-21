# Complete Multi-VM Example

Creates two zone-spread private Linux VMs with data disks, managed identity, SSH-key-only authentication, Microsoft Entra SSH login, bootstrap content, and optional application-group and Bastion RBAC.

## Usage

Supply the basic example's subnet, SSH key, storage, and Key Vault variables, plus reviewed group object IDs and optional Bastion information:

```powershell
terraform init -backend=false
terraform validate
terraform plan -var-file="environment.tfvars"
```

Applying creates billable compute, disks, extensions, NICs, and multiple RBAC assignments. Review every role scope and verify zone support, quota, bootstrap dependencies, and private administration first.
