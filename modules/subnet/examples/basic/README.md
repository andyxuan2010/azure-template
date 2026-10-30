# Basic Subnets

Creates application and data subnets in an existing VNet. The data subnet enables Storage and SQL service endpoints.

Confirm that both ranges are contained by the VNet and do not overlap existing subnets. Applying creates real network resources but no separately billed Azure service.

```powershell
terraform init -backend=false
terraform validate
terraform plan
```

## Cost and risk

- Billing: subnets and service endpoints (`Microsoft.Storage`, `Microsoft.Sql` on the data subnet) are free. Cost comes only from resources later placed in them.
- Risk: the subnets are added to an existing virtual network, so the address prefixes must not overlap other subnets. Changing an address prefix later forces subnet replacement, which fails while resources are attached.
