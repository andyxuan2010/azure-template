# Basic Azure Front Door

Creates a Standard Front Door profile, endpoint, origin group, HTTPS origin, and HTTPS-first route.

## Usage

Supply an existing resource group and reachable HTTPS origin hostname, then run `terraform init`, `terraform plan`, and `terraform apply` from this directory.

The example uses the default Front Door endpoint domain. It does not create a custom domain, DNS records, WAF policy, or origin firewall restrictions.
