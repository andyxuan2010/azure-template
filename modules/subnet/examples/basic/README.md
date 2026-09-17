# Basic Subnets

Creates application and data subnets in an existing VNet. The data subnet enables Storage and SQL service endpoints.

Confirm that both ranges are contained by the VNet and do not overlap existing subnets. Applying creates real network resources but no separately billed Azure service.

```powershell
terraform init -backend=false
terraform validate
terraform plan
```
