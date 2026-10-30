# Basic Virtual Network

Creates one explicitly named VNet without subnets or dependent network services.

Review the address space for overlap with connected networks before applying. The VNet itself has no separate hourly charge, but connected services and data transfer can.

```powershell
terraform init -backend=false
terraform validate
terraform plan
```
