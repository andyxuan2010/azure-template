# Basic Network Security Group Example

Creates an NSG with one narrowly scoped HTTPS rule. It does not associate the NSG with a subnet or NIC.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var="resource_group_name=rg-orders-dev"
```

Review the source CIDR and destination ownership before apply. Creating an NSG alone does not enforce it until an association is managed.
