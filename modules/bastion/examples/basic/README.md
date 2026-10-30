# Basic Azure Bastion Example

Creates a Basic Azure Bastion host and a new Standard static public IP in an existing resource group. Supply an existing subnet named `AzureBastionSubnet`; it must be dedicated to Bastion and have an address prefix of `/26` or larger.

Set `resource_group_name`, `location`, and `subnet_id` in a local `terraform.tfvars` file before planning. Run `terraform init -backend=false` and review `terraform plan` before applying. Bastion has ongoing hourly and data transfer charges.
