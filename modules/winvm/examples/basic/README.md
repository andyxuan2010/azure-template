# Basic Windows VM

Creates one private Windows VM with Microsoft Entra login, a system-assigned identity, and shared Storage/Key Vault role assignments.

Supply existing network and shared-IaC resources plus protected administrator credentials. Review the built-in Key Vault roles before applying. The example creates billed compute resources.

```powershell
terraform init -backend=false
terraform validate
terraform plan
```

## Cost and risk

- Billing: one Windows Server 2025 VM (`Standard_D2s_v3` by default), billed per hour for compute including the Windows licence, plus a `Standard_LRS` OS disk billed per GB per month. No data disk is created (`disksize = 0`) and no public IP (`public_network_enabled = false`). NIC, NSG and role assignments are free.
- Risk: the VM is private-only, so reach it through the virtual network or a bastion. The admin password is a sensitive input but is stored in state. Changing size, image SKU or OS disk settings can force replacement. Entra ID login is on by default and creates login role assignments, and the VM identity is granted access to the IaC storage account and Key Vault. A VM stopped from inside the OS still bills for compute; only deallocation stops it.
