# Basic NAT Gateway Example

Creates a Standard NAT Gateway, one Standard static IPv4 public IP, and associations to existing subnets in one VNet. Set `resource_group_name`, `location`, and `subnet_ids` in a local `terraform.tfvars` file before planning.

Run `terraform init -backend=false` and review `terraform plan` before applying. A NAT Gateway and its public IP have ongoing charges. Associating it changes outbound egress for every supplied subnet.
