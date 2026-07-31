# Availability Set SQL VMs

Creates two SQL Server VMs in an existing Availability Set. This pattern is for regions or designs that do not use Availability Zones.

The Availability Set must be in the same resource group and region. This example does not create clustering, a listener, or a SQL availability group and incurs VM, SQL licensing, and disk costs.

```powershell
terraform init -backend=false
terraform validate
terraform plan
```
