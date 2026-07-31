# Validation Summary

This document summarizes repository validation conventions and the modules normalized during the current documentation-standard rollout. Continuous integration remains the source of truth for each commit.

## Normalized Reference Modules

| Module | Canonical docs | Executable examples | Test classification |
| --- | --- | --- | --- |
| `acr` | `README.md` | `basic`, `complete` | `integration.tftest.hcl` |
| `adf` | `README.md` | `basic`, `complete`, `self-hosted-integration-runtime` | `integration.tftest.hcl` |
| `aks` | `README.md` | `basic`, `complete` | `unit.tftest.hcl` |
| `applicationgateway` | `README.md` | `basic`, `complete` | `unit.tftest.hcl` |
| `appregistration` | `README.md` | `basic`, `complete`, `workload-identity` | `unit.tftest.hcl` |
| `appservice` | `README.md` | `basic`, `complete`, focused authentication, container, storage, and Windows scenarios | `unit.tftest.hcl` |
| `appserviceplan` | `README.md` | `basic`, `complete`, `autoscale` | `unit.tftest.hcl` |
| `automationaccount` | `README.md`, `docs/architecture.md` | `basic`, `complete`, `runbooks-and-schedules` | `unit.tftest.hcl` |
| `availabilityset` | `README.md` | `basic`, `complete` | `unit.tftest.hcl` |
| `azure_ai_service` | `README.md`, `docs/architecture.md` | `basic`, `complete` | `unit.tftest.hcl` |
| `azure_ai_search` | `README.md`, `docs/architecture.md` | `basic`, `complete`, `public-firewall-nonproduction` | `unit.tftest.hcl` |
| `containerapp` | `README.md` | `basic`, `complete`, `background-worker` | `unit.tftest.hcl` |
| `cosmosdb` | `README.md`, `docs/architecture.md` | `basic`, `complete`, `serverless` | `unit.tftest.hcl` |
| `databricks` | `README.md`, `docs/architecture.md` | `basic`, `complete`, `unity-catalog-access-connector` | `unit.tftest.hcl` |
| `enterpriseapplication` | `README.md` | `basic`, `complete`, `application-proxy` | `unit.tftest.hcl` |
| `eventhub` | `README.md`, `docs/architecture.md` | `basic`, `complete`, `geo-disaster-recovery` | `unit.tftest.hcl` |
| `firewall` | `README.md`, `docs/architecture.md` | `basic`, `complete`, `virtual-hub` | `unit.tftest.hcl` |
| `fortigate` | `README.md`, `docs/architecture.md` | `basic`, `complete`, `dedicated-network` | `unit.tftest.hcl` |
| `functionapp` | `README.md`, `docs/architecture.md` | `basic`, `complete`, `windows` | `unit.tftest.hcl` |
| `keyvault` | `README.md`, `docs/architecture.md` | `basic`, `complete`, `private-endpoint` | `unit.tftest.hcl` |
| `linuxvm` | `README.md`, `docs/architecture.md`, `docs/authentication.md`, `docs/operations.md` | `basic`, `complete`, `public-ssh` | `unit.tftest.hcl` |
| `loadbalancer` | `README.md` | `basic`, `complete` | `unit.tftest.hcl` |
| `loganalytics` | `README.md` | `basic`, `governed` | `unit.tftest.hcl` |
| `logicapp` | `README.md`, `docs/architecture.md` | `basic`, `complete`, `vnet-integration` | `unit.tftest.hcl` |
| `managedidentity` | `README.md` | `basic`, `complete`, `github-oidc` | `unit.tftest.hcl` |
| `managementgroups` | `README.md`, `docs/architecture.md` | `basic`, `complete` | `unit.tftest.hcl` |
| `nsg` | `README.md` | `basic`, `complete`, `associations` | `unit.tftest.hcl` |
| `openai` | `README.md`, `docs/architecture.md` | `basic`, `complete`, `customer-managed-key` | `unit.tftest.hcl` |

These modules use generated Terraform reference tables, bounded provider major versions, independently initializable examples, and test filenames that identify provider impact.

## Validation Commands

From a module directory:

```powershell
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
terraform test
```

Refresh and verify generated documentation from the repository root:

```powershell
terraform-docs -c .terraform-docs.yml modules/<module-name>
terraform-docs -c .terraform-docs.yml --output-check modules/<module-name>
```

The root CI flow also validates the shared harness and performs one-module-at-a-time plans for changed modules. Review every legacy `live.tftest.hcl` before running it because provider behavior and apply impact are not encoded in that filename.

## Remaining Work

- Continue migrating legacy module-level `EXAMPLES.md`, quick references, status reports, and ambiguous test names in bounded batches.
- Keep root module wiring, the Modules Index, and the dependency guide synchronized with each migration.
- Prefer mocked plan tests for deterministic input and resource-shape coverage; retain real-provider integration tests only where cloud behavior must be verified.
- Treat CI results and version-control history as validation evidence rather than adding transient completion reports inside module directories.
