# Basic Private Linux VM Example

Creates one private Ubuntu VM with a system-assigned identity and SSH-key-only local authentication. It consumes an existing subnet, shared bootstrap storage account, and shared Key Vault.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=rg-orders-dev" `
  -var="subnet_id=/subscriptions/.../subnets/snet-application" `
  -var="admin_ssh_public_key=ssh-ed25519 AAAA..." `
  -var="iac_resource_group_name=rg-platform-iac" `
  -var="iac_key_vault_name=kv-platform-iac" `
  -var="iac_key_vault_id=/subscriptions/.../vaults/kv-platform-iac" `
  -var="iac_storage_account_name=stplatformiac" `
  -var="iac_storage_account_id=/subscriptions/.../storageAccounts/stplatformiac" `
  -var="iac_storage_primary_blob_endpoint=https://stplatformiac.blob.core.windows.net/"
```

Applying creates billable compute, NIC, and RBAC resources. Confirm private administration and bootstrap dependencies before apply.
