# Subscription Vending Architecture

## Modes

The module supports two modes:

1. Existing subscription: normalize an existing subscription resource ID and optionally perform management-group association, provider registration, and resource-group bootstrap.
2. New subscription: create an Azure subscription alias from a billing scope.

## Provider Boundary

Terraform provider configuration is established before resources are planned and cannot be reconfigured from a subscription ID created during that same apply. A new subscription therefore requires two stages:

```text
Stage 1: billing provider/state
  azurerm_subscription alias
            |
            v
     subscription_id output
            |
Stage 2: provider configured for new subscription
  management-group association
  provider registrations
  bootstrap resource groups
```

Use separate root configurations or states when strong lifecycle and permission isolation is required. The alias-only example intentionally disables management-group association and creates no subscription-scoped resources.

## Governance and Lifecycle

Management-group moves, provider registrations, and bootstrap resource groups affect the governance and deployability of a subscription. Protect both stages with approvals and review destructive plans. The module does not establish policy, budgets, RBAC, network topology, logging, or security tooling.

## Permissions

New-subscription mode requires billing-scope alias permissions. Bootstrap mode requires access in the target subscription plus management-group association rights when enabled. Keeping stages separate allows each execution identity to receive a narrower permission set.
