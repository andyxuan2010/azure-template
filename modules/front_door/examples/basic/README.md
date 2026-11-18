# Basic Azure Front Door

Creates a Standard Front Door profile, endpoint, origin group, HTTPS origin, and HTTPS-first route.

## Usage

Supply an existing resource group and reachable HTTPS origin hostname, then run `terraform init`, `terraform plan`, and `terraform apply` from this directory.

The example uses the default Front Door endpoint domain. It does not create a custom domain, DNS records, WAF policy, or origin firewall restrictions.

## Cost and risk

- Front Door Standard bills a fixed monthly profile fee plus usage (data transfer and requests). Check current Azure pricing for your region before applying.
- The profile, endpoint, and route are new resources; destroying the example removes the Front Door endpoint hostname.
- The default endpoint is publicly reachable and the origin has no firewall restriction, so use a non-production origin.
