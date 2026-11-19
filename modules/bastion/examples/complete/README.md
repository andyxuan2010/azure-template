# Complete Azure Bastion Example

Creates a Standard SKU Azure Bastion host across three availability zones with four scale units. It enables copy/paste, file copy, IP-based connections, native tunneling, and shareable links. Session recording and Kerberos are left disabled because they depend on tenant-level prerequisites.

Supply an existing subnet named `AzureBastionSubnet` that is dedicated to Bastion and has an address prefix of `/26` or larger. Standard SKU with several scale units has higher hourly charges than the Basic example.

## Usage

```powershell
terraform init -backend=false
terraform validate
```
