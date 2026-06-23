# Cosmos DB Validation Report

## Scope

Added a new Azure Cosmos DB Terraform module aligned with the repository module standards.

## Coverage

- Account creation with secure defaults, generated naming, standardized tags, identity, backup, consistency, geo-replication, network controls, and optional customer-managed key.
- SQL API databases and containers with throughput, autoscale, partitioning, indexing, unique keys, TTL, conflict resolution, and analytical TTL.
- Private endpoint and private DNS zone attachment or lookup.
- Account-scope Azure RBAC, Entra group lookup, custom SQL data-plane role definitions, and SQL role assignments.
- Diagnostics to Log Analytics, Storage Account, or Event Hub.
- Mock-provider Terraform tests for secure defaults, generated naming, and private endpoint plus diagnostics and RBAC scenarios.

## Validation Commands

```powershell
terraform fmt -recursive modules/cosmosdb
terraform -chdir=modules/cosmosdb init -backend=false -input=false
terraform -chdir=modules/cosmosdb validate
terraform -chdir=modules/cosmosdb test
```

## Result

Passed locally:

- `terraform -chdir=modules/cosmosdb validate`
- `terraform -chdir=modules/cosmosdb test`
- `terraform validate`
- `terraform test -filter=tests/root-plan.tftest.hcl`
