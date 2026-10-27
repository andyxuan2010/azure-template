# Azure Policy Architecture

```text
management group (optional definition scope)
                |
                v
      custom policy definition
                |
                v
management group | subscription | resource group
                |
                v
       optional assignment
```

## Definition and Assignment Ownership

A policy definition describes a governance rule. An assignment activates that rule at a scope. This module can own both, but separate stacks are preferable when a platform team owns definitions and environment teams control assignments.

## Inheritance and Blast Radius

Management group assignments affect descendant subscriptions and resource groups unless excluded. Subscription assignments affect all contained resource groups. Treat scope changes, enforcement changes, parameter changes, and `not_scopes` changes as high-impact governance operations.

## Identity Boundary

A system-assigned assignment identity is required by some `deployIfNotExists` and `modify` policies. The identity alone is insufficient: role assignments must be granted separately and should be limited to the scope and permissions required for remediation.

## Deployment Sequence

1. Create or select the management group hierarchy.
2. Create the custom definition.
3. Review aliases, effects, parameters, exclusions, and non-compliance messages.
4. Create a non-enforcing or audit assignment where appropriate.
5. Grant remediation identity permissions when required.
6. Promote enforcement only after compliance results are understood.

The module does not create remediation tasks; those remain an explicit operational action.
