# Automation Account Module - Architecture Review

## Scope

This review covers `modules/automationaccount` and evaluates security posture, network design, observability, identity, RBAC, operational resources, and testability.

## Architecture

The module provisions:

- `azurerm_automation_account`
- Optional runbooks, schedules, job schedules, and Automation variables
- Optional managed identity, customer-managed key encryption, and RBAC
- Optional private endpoints for Webhook and DSC/Hybrid Worker connectivity
- Optional diagnostic settings to Log Analytics, Storage Account, and Event Hub

## Security Baseline

- Local authentication defaults to disabled.
- Public network access defaults to disabled.
- System-assigned managed identity defaults to enabled.
- User-assigned managed identities are supported for CMK and identity reuse.
- CMK configuration requires a managed identity and validates Key Vault key IDs.
- Entra group RBAC supports object IDs to avoid display-name ambiguity.
- Generic RBAC validates principal IDs, principal types, and mutually exclusive role definition inputs.

## Network Design

- Private endpoint creation is explicit and supports both Webhook and DSC/Hybrid Worker subresources.
- Existing legacy VNet lookup inputs remain supported for compatibility.
- Direct `private_endpoint_subnet_id` is preferred for portability and avoids provider data-source lookups.
- Private DNS zone linking is optional and explicit through `private_dns_zone_id`.

## Observability

- Diagnostics can be enabled explicitly or by supplying a destination.
- Supported destinations are Log Analytics, Storage Account archive, and Event Hub.
- Diagnostic log categories and Azure Monitor category groups are separate inputs.
- Default log categories provide useful operational telemetry when diagnostics are enabled.

## Operations

- Runbooks can be created from inline content or external publish content links.
- Schedules support one-time, hourly, daily, weekly, and monthly cadence patterns.
- Job schedules can reference runbooks and schedules created by the module by map key.
- Automation variables support string, bool, int, datetime, and object values.
- Sensitive values should not be stored through Terraform unless the state backend is protected.

## Risks And Tradeoffs

- Terraform state can contain Automation variable values, including values marked encrypted in Azure.
- Private endpoint subnet and DNS readiness remain responsibilities of network/platform modules.
- Runbook source URLs should be pinned to stable content or reviewed release artifacts.
- Deterministic generated names can collide if callers reuse the same naming segments.

## Recommendations

1. Use private endpoints and keep `public_access_enabled = false` for production.
2. Keep `local_auth_enabled = false` and use RBAC-first access.
3. Prefer object IDs for Entra groups and direct subnet IDs for private endpoints.
4. Route diagnostics to centralized Log Analytics and archive destinations where retention policy requires it.
5. Avoid secrets in Automation variables managed by Terraform; use Key Vault or protected state when unavoidable.

## Test Coverage

`tests/live.tftest.hcl` covers named resources, deterministic generated naming, standardized tags, identity, RBAC, diagnostics, private endpoints, runbooks, schedules, job schedules, and variables using plan-based Terraform tests.
