# Cost and Budget Guide

Terraform plans describe proposed infrastructure changes; they do not, by themselves, establish the full monthly operating cost. Use this guide to find cost drivers and arrange an approved estimate before deployment.

## What affects cost

- Azure region, redundancy, service tier, and reserved capacity;
- compute size, uptime, autoscaling, and idle resources;
- storage capacity, transactions, retention, backup, and replication;
- network egress, gateways, private endpoints, and public IPs;
- monitoring ingestion and retention;
- development, sandbox, and production copies of shared services;
- data/AI request volume and service-specific usage meters.

Module examples are illustrative. They are not a commitment that a configuration meets a budget or workload SLO.

## Estimate before provisioning

1. Select the module example closest to the intended workload and identify all enabled resources.
2. Confirm Azure region, SKU, capacity, redundancy, retention, and expected usage with the service owner.
3. Review a fresh Terraform plan for new resources, replacements, and ongoing services.
4. Use the organization's approved Azure pricing or FinOps process for an estimate; record assumptions, currency, region, and estimate date.
5. Obtain the required budget owner approval and define budget alerts or cost anomaly monitoring before production use.
6. Revisit the estimate after deployment using actual Azure cost data and tags.

This repository does not contain approved workload budgets or current price quotes. Prices and Azure meters change; use live pricing data for the selected region and date.

## Cost ownership

Confirm owners for the workload, subscription, budget, and cost alerts before applying. Follow the [Tagging Standard](../60-security-governance/tagging-standard.md) so resources can be attributed to the correct workload and environment. Do not assume a tag alone creates chargeback or a budget alert.

## Useful review questions

- Which resources remain billable when the application is idle?
- Which tiers or retention settings are set by module defaults?
- Are backups, replicas, gateways, or monitoring retained after a test?
- What will scale with requests, data volume, network transfer, or time?
- Who reviews cost after deployment and who can approve a change in capacity?

For shared-state deletion, confirm recovery and data-retention needs before removal; see [Destroy a Resource](destroy-a-resource.md).
