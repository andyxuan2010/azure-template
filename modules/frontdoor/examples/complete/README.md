# Complete Premium Front Door

Creates a Premium Front Door profile and route to a supported Azure origin through Private Link.

## Usage

Supply an existing resource group, the origin hostname and resource ID, and the region for the Private Link connection. Run `terraform init`, `terraform plan`, and `terraform apply` from this directory.

Azure requires manual approval of the Front Door Private Link connection request. Confirm the request on the target origin before relying on the route. This example does not configure a WAF policy or custom domain.
