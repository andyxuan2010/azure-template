# Stakeholder Reading Guide

This page routes readers to the material they need. It does not claim that a configured control has been exercised successfully or that a service-level commitment exists.

| Reader | Start with | Then review |
| --- | --- | --- |
| Executives | [Executive Summary](../../README.md#executive-summary) | [Platform Operating Model](../10-architecture/platform-operating-model.md), [Cost and Budget Guide](../50-operations/cost-and-budget-guide.md), and [Validation Summary](../70-validation/validation-summary.md). |
| CTO and platform owners | [Repository Architecture](../10-architecture/repository-architecture.md) | [Platform Operating Model](../10-architecture/platform-operating-model.md), [DevSecOps and GitOps Controls](../60-security-governance/devsecops-gitops.md), and [Environment Lifecycle](../30-deployment/environment-lifecycle.md). |
| Solution and enterprise architects | [Repository Architecture](../10-architecture/repository-architecture.md) | [Module Usage and Dependencies](../20-repository/module-usage-and-dependencies.md), [Entra Identity and RBAC](../60-security-governance/entra-identity-and-rbac.md), and [Architecture Decision Records](../10-architecture/architecture-decision-records.md). |
| Terraform engineers | [Repository Map](repo-map.md) | [First Change Walkthrough](first-change.md), [Modules Index](../20-repository/modules-index.md), [Module Documentation Standard](../20-repository/module-documentation-standard.md), and the selected module README. |
| DevOps engineers | [Environment Lifecycle](../30-deployment/environment-lifecycle.md) | [GitHub Actions Pipeline](../40-pipelines/github-actions-pipeline.md), [Azure DevOps Pipeline](../40-pipelines/azure-devops-pipeline.md), and [Operations Handbook](../50-operations/operations-handbook.md). |
| Security and governance | [DevSecOps and GitOps Controls](../60-security-governance/devsecops-gitops.md) | [Entra Identity and RBAC](../60-security-governance/entra-identity-and-rbac.md), [Naming Convention](../60-security-governance/naming-convention.md), and [Tagging Standard](../60-security-governance/tagging-standard.md). |
| Finance and service owners | [Cost and Budget Guide](../50-operations/cost-and-budget-guide.md) | [Tagging Standard](../60-security-governance/tagging-standard.md), module READMEs, and the approved deployment plan for the specific workload. |

## Questions this repository can answer

- **What can the catalog build?** Start with the [module portfolio in the README](../../README.md#what-is-in-this-repository) and the [Modules Index](../20-repository/modules-index.md).
- **How does a change get reviewed and deployed?** Read the [Environment and Deployment Lifecycle](../30-deployment/environment-lifecycle.md).
- **How are identities and permissions represented?** Read [Entra Identity and RBAC](../60-security-governance/entra-identity-and-rbac.md).
- **What should happen when state or a pipeline fails?** Use the [Operations Handbook](../50-operations/operations-handbook.md).

## Questions requiring an owner or live evidence

This source repository alone cannot establish current Azure health, actual deployed resources, approved budgets, measured cost, business service criticality, support SLAs, or whether all GitHub/Azure DevOps settings match the documented intent. Confirm those items with the named service, platform, security, and finance owners before relying on them.
