# Recovery Services Vault: Complete Example

This example deploys a Recovery Services vault with geo-redundant storage, cross-region restore enabled, and unlocked immutability. It expects the target resource group to exist.

## Run

```powershell
terraform init
terraform plan -var="resource_group_name=<existing-resource-group>"
```

Set Azure authentication through the AzureRM provider's supported environment or CLI flow before planning. Review the plan and confirm the subscription, region, vault name, and recovery settings before applying.

This example creates Azure resources when applied. Use an approved non-production subscription and remove the vault only after confirming that it contains no protected workloads or recovery points.

## Cost and risk

- Geo-redundant storage costs more than locally redundant storage. Azure Backup bills for protected instances and stored recovery points, so check current Azure pricing before applying.
- Cross-region restore can add data transfer charges during restores.
- Unlocked immutability can still be changed. A locked configuration is irreversible, so this example does not lock it.
