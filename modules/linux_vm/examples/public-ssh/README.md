# Public SSH Linux VM Example

Creates one Linux VM with a public IP and an NSG that permits SSH only from caller-supplied trusted prefixes. This pattern is intended for exceptional, approved cases.

## Usage

Supply the basic example's subnet, SSH key, storage, and Key Vault variables plus narrow source addresses:

```powershell
terraform init -backend=false
terraform validate
terraform plan -var='trusted_ssh_source_prefixes=["203.0.113.10/32"]' -var-file="environment.tfvars"
```

Never use `0.0.0.0/0` or `::/0`. Prefer Bastion or private connectivity. Applying creates billable VM, public IP, NIC, NSG, and RBAC resources.
