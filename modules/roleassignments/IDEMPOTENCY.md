# Idempotency Design

This document explains how the `roleassignments` module avoids duplicate Azure RBAC creation while keeping the module input generic.

## Goal

The design goal is:

- allow callers to describe desired role assignments declaratively
- avoid duplicate logical assignments inside a single Terraform input set
- generate stable role assignment names for repeatable Terraform-managed assignments
- keep support for either `principal_id` or `principal_name`
- keep support for either `role_definition_id` or `role_definition_name`

## Problem Statement

Terraform state idempotency alone is not enough for RBAC.

Terraform state idempotency covers assignments already managed by the current state.
This case still requires an import:

1. A matching role assignment already exists in Azure.
2. It is not tracked in the current Terraform state.
3. Terraform tries to create it again.
4. Azure rejects the create request because the assignment already exists.

This module does not query Azure-side role assignments during plan because some callers
pass scopes created in the same apply, and those scope IDs are unknown during planning.

## Design Summary

The module uses Terraform state plus deterministic role assignment names.

### Deterministic Names

The module normalizes every assignment and builds the Azure role assignment name from:

- `scope`
- resolved role identity
- resolved principal identity
- `principal_type`
- `condition`
- `condition_version`

This keeps Terraform-managed assignments stable across repeated plans and applies.

## Resolution Flow

For each desired assignment:

1. Normalize raw input values.
2. Resolve `principal_name` to an Entra group object ID when `principal_id` is absent.
3. Resolve `role_definition_name` to a role definition resource ID when `role_definition_id` is absent.
4. Build the desired assignment identity key.
5. Generate a deterministic role assignment name.
6. Create or update the Terraform-managed assignment.

## Why Resolve To IDs

The module compares role and principal identities using resolved IDs because:

- Azure stores role assignments using role definition IDs
- principal names are not stable identifiers
- role names can be ambiguous across custom scopes

Using IDs gives consistent comparison behavior across built-in and custom roles.

## What The Module Does Not Do

The module does not import existing Azure role assignments into Terraform state.

Behavior is:

- assignment already in Terraform state: managed normally
- missing assignment: created
- matching assignment outside Terraform state: not adopted automatically

If you want Terraform to manage a preexisting assignment explicitly in state, import it yourself.

## Operational Impact

This avoids plan-time failures when scopes are produced by resources in the same
configuration. Existing Azure assignments outside Terraform state must be imported
before applying if the module should manage them.
