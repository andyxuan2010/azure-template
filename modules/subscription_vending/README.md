# Subscription Vending Module

Provision or bootstrap a landing-zone subscription by optionally creating a subscription alias, associating the subscription to a management group, registering resource providers, and creating bootstrap resource groups.

## Overview

- Providers: `azurerm`
- Use case: subscription onboarding and initial platform bootstrap
- Terraform requirement: `>= 1.6`
- Terraform tests: deterministic mocked plan tests in `tests/live.tftest.hcl`

## Provider Scope

The AzureRM provider passed to this module must target the subscription being bootstrapped before resource-provider registrations and bootstrap resource groups can be created there. Terraform provider configuration cannot be switched dynamically from the subscription ID produced by a resource.

For a newly created subscription, use two stages:

1. Create the subscription alias and expose `subscription_id`.
2. Configure an AzureRM provider for that subscription, then run the management-group association, provider registrations, and bootstrap resource groups.

## Validation

- Alias creation requires `subscription_alias_name` and a Microsoft Billing scope ID.
- Existing-subscription mode requires a full `/subscriptions/<guid>` resource ID.
- Management-group association requires `management_group_id`.
- Resource provider namespaces must use the `Microsoft.*` form.
