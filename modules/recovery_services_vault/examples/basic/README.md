# Basic Recovery Services vault

Creates a zone-redundant Recovery Services vault with unlocked immutability for Azure Backup workloads in the same region.

## Usage

Supply an existing `resource_group_name` and the region shared by the vault and protected data sources, then run `terraform init`, `terraform plan`, and `terraform apply` from this directory.

The example creates the vault only. Configure workload-specific backup policies and protected items separately after reviewing retention, recovery objectives, and service requirements.

## Cost and risk

- The vault itself has no fixed fee; Azure Backup bills for protected instances and backup storage once items are protected. Zone-redundant storage costs more than locally redundant storage.
- Immutability is created unlocked, so it can still be changed. Locking it is irreversible, so do not lock it in a trial.
- Soft-deleted backup data can keep incurring storage charges after the vault is destroyed or items are removed. Review retention before cleaning up.
