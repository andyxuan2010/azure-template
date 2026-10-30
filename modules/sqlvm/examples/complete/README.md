# Complete SQL VM Tier

Creates two zone-spread SQL Server VMs with static private addresses, Azure Hybrid Benefit, the standard data/log/TempDB disk layout, SQL storage paths, and assessment enabled.

Confirm AHUB eligibility, zonal image/SKU support, IP availability, quota, and the application high-availability design before applying. This example creates costly compute, licensing, and disk resources.

```powershell
terraform init -backend=false
terraform validate
terraform plan
```
