# Idempotency Design

This document explains how the `roleassignments` module avoids duplicate Azure RBAC creation while keeping the module input generic.

## Goal

The design goal is:

- allow callers to describe desired role assignments declaratively
- avoid duplicate logical assignments inside a single Terraform input set
- avoid `RoleAssignmentExists` failures when matching assignments already exist in Azure
- keep support for either `principal_id` or `principal_name`
- keep support for either `role_definition_id` or `role_definition_name`

## Problem Statement

Terraform state idempotency alone is not enough for RBAC.

Without Azure-side discovery, this case fails:

1. A matching role assignment already exists in Azure.
2. It is not tracked in the current Terraform state.
3. Terraform tries to create it again.
4. Azure rejects the create request because the assignment already exists.

That was the gap this design closes.

## Design Summary

The module now uses a two-layer idempotency model:

1. Input-level deduplication
2. Azure-side existence filtering

### 1. Input-Level Deduplication

The module normalizes every assignment and builds a logical identity key from:

- `scope`
- resolved role identity
- resolved principal identity
- `principal_type`
- `condition`
- `condition_version`

This prevents duplicate logical assignments from being accepted in the same input set.

### 2. Azure-Side Existence Filtering

For each distinct assignment scope, the module:

- queries existing Azure role assignments with `azapi_resource_list`
- resolves the desired role definition to a resource ID
- resolves the desired principal to an object ID when needed
- compares the desired logical identity key to the existing Azure assignments
- creates only the assignments that are missing

## Resolution Flow

For each desired assignment:

1. Normalize raw input values.
2. Resolve `principal_name` to an Entra group object ID when `principal_id` is absent.
3. Resolve `role_definition_name` to a role definition resource ID when `role_definition_id` is absent.
4. Build the desired assignment identity key.
5. Read existing role assignments for that scope from Azure.
6. Build existing assignment identity keys from Azure response data.
7. Drop any desired assignment whose identity key already exists in Azure.
8. Create only the remaining assignments.

## Matching Rules

A desired assignment is considered already present when all of the following match:

- `scope`
- role definition resource ID
- principal object ID
- `principal_type`
- `condition`
- `condition_version`

This is intentionally stricter than matching only on scope, role name, and principal name.

## Why Resolve To IDs

The module compares role and principal identities using resolved IDs because:

- Azure stores role assignments using role definition IDs
- principal names are not stable identifiers
- role names can be ambiguous across custom scopes

Using IDs gives consistent comparison behavior across built-in and custom roles.

## What The Module Does Not Do

The module does not import existing Azure role assignments into Terraform state.

Behavior is:

- existing matching Azure assignment: skipped
- missing assignment: created
- existing assignment not in state: not adopted automatically

If you want Terraform to manage a preexisting assignment explicitly in state, import it yourself.

## Operational Impact

Benefits:

- repeated applies are safer
- shared enterprise scopes are less likely to hit duplicate RBAC failures
- callers no longer need to implement Azure-side dedupe logic outside the module

Tradeoff:

- skipped assignments may still exist outside Terraform state, so state will not fully enumerate all matching Azure RBAC unless those assignments are imported
