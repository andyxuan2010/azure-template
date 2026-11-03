# Platform Operating Model

This guide describes how teams are expected to use and govern this repository. It is based on repository configuration and documentation; it does not assert that a particular Azure service is currently deployed or that an operational SLA has been approved.

## Platform capability

The repository supplies reusable Azure Terraform modules, executable examples, tests, and a root validation/composition harness. Teams can consume modules independently or use root wiring for selected combinations. The catalog does not provision one always-on platform environment by itself.

## Consumer lifecycle

1. A consumer identifies a module and checks its caller-owned prerequisites.
2. The consumer supplies providers, identity, target subscription, backend, and workload inputs from its own controlled configuration.
3. Changes are reviewed and validated through the repository's documented CI gates.
4. A plan is reviewed before an approved apply. Module publication or snapshot synchronization is a separate optional pipeline outcome.
5. The consumer owns workload-specific monitoring, recovery, and ongoing service operation unless a separate service agreement assigns those responsibilities elsewhere.

## Responsibility boundaries

| Concern | Repository responsibility | Consumer or platform-owner responsibility |
| --- | --- | --- |
| Module behavior | Reusable resource code, documented inputs/outputs, examples, and tests. | Select, configure, and support modules for a workload. |
| Authentication | Documents pipeline secret and identity expectations. | Provision identities, credentials, service connections, and least-privilege access. |
| State | Provides backend configuration examples and recovery guidance. | Verify backend protections, access, locking, retention, and recovery readiness. |
| Deployment | Defines workflow conditions and plan/apply gates. | Configure branch rules, protected environments, approvals, variables, and credentials. |
| Cost | Exposes configuration that can create Azure resources. | Estimate workload costs, approve budgets, monitor actual spend, and own chargeback. |
| Service operation | Provides reusable building blocks and operational guidance. | Define service owner, support model, alerts, availability targets, backup, and incident response. |

## Governance points

- Treat root Terraform as a plan and validation harness, not as proof of the deployed estate.
- Keep `prod/backend.hcl` as a placeholder until its values and protections are reviewed and approved.
- Apply the exact plan reviewed by the change process. Re-plan if code, state, or cloud resources change.
- Use environment-specific credentials and approvals. GitHub environments and Azure DevOps variable groups are configured separately.
- Review changes to shared modules for compatibility and downstream impact.

## Ownership information to maintain

Platform owners should keep the following current in the organization’s approved ownership system and link it from this guide:

- module and pipeline maintainers;
- escalation route and support hours;
- service criticality and recovery objectives;
- production approval authorities;
- security and cost owners;
- deprecation and migration policy for shared module interfaces.

These values are intentionally not invented in this repository. Add them only after the responsible owners confirm them.

## Related guides

- [Repository Architecture](repository-architecture.md)
- [Architecture Decision Records](architecture-decision-records.md)
- [Environment and Deployment Lifecycle](../30-deployment/environment-lifecycle.md)
- [Cost and Budget Guide](../50-operations/cost-and-budget-guide.md)
- [Stakeholder Reading Guide](../00-start-here/stakeholder-guide.md)
