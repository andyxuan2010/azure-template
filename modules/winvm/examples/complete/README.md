# Complete Windows VM Tier

Creates two zone-spread private Windows VMs with static addresses, data disks, Microsoft Entra group access, VM Run Command bootstrap, and Log Analytics diagnostics.

Populate the shared Storage `scripts` container before apply and provide a content hash when external assets change. Confirm IP availability, quota, identity permissions, guest outbound access, and compute/monitoring costs.

```powershell
terraform init -backend=false
terraform validate
terraform plan
```
