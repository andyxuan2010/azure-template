# Complete Premium Front Door

Creates a Premium Front Door profile and route to a supported Azure origin through Private Link.

## Usage

Supply an existing resource group, the origin hostname and resource ID, and the region for the Private Link connection. Run `terraform init`, `terraform plan`, and `terraform apply` from this directory.

Azure requires manual approval of the Front Door Private Link connection request. Confirm the request on the target origin before relying on the route. This example does not configure a WAF policy or custom domain.

## Cost and risk

- Front Door Premium has a substantially higher fixed monthly profile fee than Standard, plus usage charges. Check current Azure pricing before applying.
- Private Link to the origin may add per-connection and data-processing charges.
- The route does not work until the Private Link connection is approved on the origin, so confirm approval before directing traffic to the endpoint. Destroy the example promptly if it is only a trial.
