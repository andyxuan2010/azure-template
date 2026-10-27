# Basic Recovery Services vault

Creates a zone-redundant Recovery Services vault with unlocked immutability for Azure Backup workloads in the same region.

## Usage

Supply an existing `resource_group_name` and the region shared by the vault and protected data sources, then run `terraform init`, `terraform plan`, and `terraform apply` from this directory.

The example creates the vault only. Configure workload-specific backup policies and protected items separately after reviewing retention, recovery objectives, and service requirements.
