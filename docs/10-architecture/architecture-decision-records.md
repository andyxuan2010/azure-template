# Architecture Decision Records

Architecture Decision Records (ADRs) preserve the reasoning behind choices that affect multiple modules, consumers, security boundaries, or operations. This page defines how to add them; it does not reconstruct undocumented historical discussions.

## Current architectural constraints visible in the repository

- The repository is a reusable module catalog with a root validation/composition harness, not one permanently deployed environment.
- Providers and credentials belong to the caller; modules expose inputs and outputs for composition.
- The root harness supports broad feature selection and focused module planning. A catalog module is not automatically root-wired.
- The `dev` and `sandbox` backend files are populated. The `prod` backend file is a placeholder and must not be used.
- GitHub Actions and Azure DevOps have distinct configuration and deployment paths. Do not assume a GitHub environment setting configures an Azure DevOps variable group.

For current implementation details, see [Repository Architecture](repository-architecture.md), the [Root-Level Module Guide](../20-repository/root-level-modules-guide.md), and the [Environment Lifecycle](../30-deployment/environment-lifecycle.md).

## When to write an ADR

Write one when a decision changes or establishes a shared interface, platform dependency, identity/trust model, network boundary, state strategy, promotion path, security control, or support responsibility. Module-local implementation details belong in the module README unless they affect other consumers.

## ADR template

Create a numbered Markdown file such as `docs/90-decisions/0001-use-managed-identity-for-ci.md`:

```markdown
# ADR 0001: <short decision title>

- Status: proposed | accepted | superseded | rejected
- Decision owners: <team or named roles>
- Date: YYYY-MM-DD

## Context
What problem or constraint requires a decision?

## Decision
What choice was made, and where does it apply?

## Alternatives considered
List realistic alternatives and why they were not selected.

## Consequences
Describe benefits, costs, risks, migration, and operational responsibilities.

## Evidence and links
Link to implementation, security review, or approved design record.
```

## Review and lifecycle

ADRs should be reviewed by the owning platform and security roles when their domains are affected. Once accepted, link the ADR from impacted architecture and module guides. Do not silently rewrite a decision after implementation; mark the old record superseded and add a new ADR with the migration path.
