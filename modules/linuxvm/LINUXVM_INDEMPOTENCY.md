# Linux VM Idempotency Review

## Scope

This note rescans the current `linuxvm` module with emphasis on the RBAC path, because that has been the hardest idempotency problem in this module.

Primary files reviewed:

- `main.tf`
- `locals.tf`
- `data.tf`
- `outputs.tf`
- recent `git log` history for the last two days of `linuxvm` RBAC changes

Important note:

- I cannot see external chat transcripts beyond this thread.
- The summary below reconstructs the recent struggle from the code, current design, and recent git history.

## Executive Summary

The main technical difficulty in `linuxvm` is not the VM resource itself. It is the role-assignment lifecycle around:

- VM resource `Contributor` and `Reader`
- NIC `Contributor`
- app resource group `Reader`
- Bastion resource group `Reader`
- Bastion host `Network Contributor`
- optional Entra login role assignments

What makes this hard is the combination of:

- Azure RBAC uniqueness rules
- pre-existing unmanaged assignments in Azure
- exact-scope matching requirements
- AzAPI query shape differences
- `for_each` key stability
- the difference between "skip creating duplicates" and "actually manage the desired assignment in Terraform"

The good news is that the module is in a better place now than it was at the start of the last two days. The bad news is that the RBAC path is still the most fragile part of the module and deserves the strongest emphasis in this review.

## Current RBAC Design

### Direct Terraform-managed role assignments

The module creates RBAC resources directly in [`main.tf`](main.tf#L268):

- [`vm_resource_admin`](main.tf#L268) gives `Contributor` on each VM
- [`nic_resource_admin`](main.tf#L278) gives `Contributor` on each NIC
- [`vm_resource_user`](main.tf#L288) gives `Reader` on each VM

The VM and NIC role assignments are straightforward because they are created on resources the module itself owns.


### Historical note

The app resource group and Bastion RBAC paths that drove most of the idempotency complexity have now been removed from the module. This document is preserved as historical context for the earlier debugging and design work.

## What We Were Struggling With

Based on the git history from April 7-8, 2026, the last two days were mostly a cycle of trying to make RBAC idempotent without breaking Terraform lifecycle behavior.

The commit trail shows repeated fixes in these areas:

- detecting existing assignments in Azure
- using the correct AzAPI query shape
- choosing the right query scope
- choosing stable `for_each` keys
- deciding whether to exclude existing assignments from creation maps
- trying import blocks, then removing them

The recent history includes:

- `bee5fcd` "Add idempotency to role assignments: only create if not already existing"
- `3967549` "Fix linuxvm role assignment maps to use principal_id keys for idempotency"
- `047118b`, `0c87b1a`, `6d044cb`, `736dce6`, `7b633b5`, `ef9176b`, `90e71bc`, `b21ed40`, `6441891` for different AzAPI scope/filter approaches
- `3cc9306` "Fix role assignment idempotency: exclude existing principals from creation maps"
- `7f2c7cd` "Fix linuxvm RBAC role assignment lifecycle"
- `4f5e6e8` "Remove invalid linuxvm module import blocks"

That sequence strongly suggests the core struggle was:

1. detect existing Azure assignments reliably
2. avoid `RoleAssignmentExists` conflicts
3. keep `for_each` stable
4. preserve Terraform ownership/lifecycle for desired assignments
5. avoid invalid module-level import behavior

## Root Causes

### 1. Exact scope matching matters more than it first appears

The module needs to distinguish between:

- `Reader` on the app resource group
- `Reader` on a child resource inside that resource group
- `Network Contributor` on the Bastion host
- `Network Contributor` on the Bastion resource group

Those are not interchangeable.

The current AzAPI filters correctly match on exact scope in [`data.tf`](data.tf#L43):

- `properties.scope == '${data.azurerm_resource_group.app.id}'`
- `properties.scope == '${data.azurerm_bastion_host.app[0].id}'`
- `properties.scope == '${data.azurerm_resource_group.bastion[0].id}'`

This is one of the biggest lessons from the recent fixes: RBAC "close enough" scope matching is not good enough.

### 2. AzAPI query shape was easy to get wrong

The history shows multiple attempts around:

- subscription-level parent query versus resource-level parent query
- `properties.roleDefinitionId` versus top-level `roleDefinitionId`
- `properties.scope` versus top-level `scope`
- `regex` matching versus `contains`

That tells us the team was fighting both Azure API response shape and JMESPath filter behavior.

Current code uses resource-scope `parent_id` and filters against `properties.roleDefinitionId` plus exact `properties.scope`. That appears to be the settled working pattern.

### 3. Skipping creation is not the same as stable lifecycle

One earlier approach was:

- discover existing principals in Azure
- subtract them from the desired set
- only create the remainder

That does avoid duplicate-create failures, but it has a lifecycle downside:

- the desired assignment exists conceptually
- Terraform does not manage it
- outputs and lifecycle become inconsistent
- later behavior depends on whether the assignment pre-existed outside state

The history around `bee5fcd`, `3cc9306`, and `7f2c7cd` points directly at this tension.

### 4. `for_each` key choice was part of the idempotency bug

Earlier variants used keys derived from group labels like:

- `app_admin_<group>`
- `app_user_<group>`

That can work, but it creates awkward behavior when the real uniqueness you care about is the resolved `principal_id`.

The later shift toward principal-based maps is a real improvement because:

- principal IDs are the actual Azure identity
- group principal IDs are required for RBAC inputs
- dedupe behavior should happen on resolved principal identity, not on human labels

### 5. Import blocks were not a clean fit here

The recent `7f2c7cd` commit added `import {}` blocks for existing discovered assignments, and `4f5e6e8` removed them right after as invalid for this module flow.

That is an important outcome:

- the idea was correct in spirit
- the implementation path was not valid in this location or usage pattern

So the module is currently in an in-between state:

- it discovers existing assignments
- it exposes enough data to help import/debug
- but it does not automatically adopt existing assignments into state

## Current State of the Fix

### What is improved

The RBAC path is materially better now because:

- AzAPI queries are narrower and match exact scopes
- the module now captures both `principal_id` and assignment `id`
- the locals separate desired assignments from existing discovered assignments
- principal-based `for_each` logic is more stable than the earlier label-based maps
- debug outputs are aligned with role-assignment objects, not only raw principal lists

This means the module now documents and exposes the problem much more clearly.

### What is only partially fixed

The bug is still only partially fixed because the hardest lifecycle question remains unresolved:

- if the exact desired assignment already exists in Azure but is not in Terraform state, what should the module do?

Right now the answer is effectively:

- detect it
- expose enough information to debug it
- expect a manual/root-module import path where needed

That is workable, but it is not fully self-healing idempotency.

## Analysis By Role Assignment Type

### VM and NIC RBAC

These are the least risky:

- VM `Contributor`
- NIC `Contributor`
- VM `Reader`

Why:

- the module creates those resources itself
- the scopes are resource IDs owned by the module
- collisions with unrelated pre-existing assignments are less likely

### App resource group `Reader`

This is one of the main pain points.

Why:

- the scope is shared
- assignments often already exist
- the module wants the same principals across both admin and user groups
- exact-scope detection matters

This path now depends on the correctness of:

- the AzAPI discovery query
- the principal resolution logic
- the `for_each` map built from desired principal IDs

### Bastion resource group `Reader`

This has the same shared-scope problem as the app resource group `Reader`, plus an extra optional-feature branch because it only exists when Bastion is configured.

That makes it easier for edge cases to hide until a specific environment enables Bastion.

### Bastion host `Network Contributor`

This appears to have been the hardest single role-assignment path.

Why:

- it is not the same scope as the Bastion resource group
- earlier changes moved between resource-group scope and host scope
- duplicate assignments here are likely in real environments
- exact-scope matching is mandatory

The history shows several reversals specifically around Bastion scope and discovery logic, which is a strong signal that this was a real bug source rather than a documentation-only concern.

## Idempotency Risks That Still Matter

### 1. Existing unmanaged Azure RBAC can still break apply

If the module wants to create an assignment that already exists in Azure and the existing object is not in Terraform state, the module can still end up in a conflict scenario depending on how the current maps are used in practice.

### 2. Detection and ownership are still separate concerns

The module is much better at detection than before.

But detection alone does not solve:

- state adoption
- lifecycle consistency
- drift visibility

### 3. Debug visibility is present, but operational workflow is still manual

The debug outputs in [`outputs.tf`](outputs.tf#L108) help, but the operational fix still appears to be:

- inspect the discovered existing assignments
- import them from the root module if needed
- rerun apply

That is acceptable operationally, but it is not the same as full automation.

## Recommended Emphasis For This Module

If this document is meant to highlight the real risk area, the strongest message should be:

- Terraform idempotency for `linuxvm` is mostly fine for compute/network resources.
- RBAC idempotency is the real problem area.
- The critical failure mode is pre-existing Azure role assignments at shared scopes.
- Exact-scope AzAPI filtering and stable `for_each` identity are the key mechanics.
- The recent fixes improved detection a lot, but ownership/adoption of pre-existing assignments is still only partially solved.

## Recommended Next Steps

1. Keep the RBAC discussion front-and-center in module docs, not buried under generic VM idempotency notes.
2. Document the exact scopes that count as matches:
   app resource group, Bastion resource group, and Bastion host are all different.
3. Document the operational rule clearly:
   if a matching role assignment already exists at the exact target scope, import it from the root module before apply.
4. Add targeted test coverage specifically for:
   pre-existing app resource group `Reader`
   pre-existing Bastion resource group `Reader`
   pre-existing Bastion host `Network Contributor`
5. Keep principal ID as the identity anchor for RBAC maps whenever possible.
6. Avoid drifting back to broad subscription queries or loose scope matching unless there is a verified Azure API reason.

## Bottom Line

The last two days of changes show that the team was not fighting a simple typo. The struggle was architectural:

- how to discover existing Azure RBAC reliably
- how to compare it at the exact intended scope
- how to keep `for_each` addresses stable
- how to avoid duplicate-create failures
- how to do all of that without breaking Terraform lifecycle expectations

The current module is better than it was:

- exact-scope AzAPI discovery is stronger
- principal-based maps are better
- role-assignment debug visibility is better

But the RBAC bug is only partially fixed because automatic adoption of pre-existing assignments is still not fully resolved inside the module lifecycle. That is the part this file should emphasize most strongly.
