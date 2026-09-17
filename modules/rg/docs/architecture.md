# Resource Group Architecture

```text
subscription
    |
    v
resource group
  |    |      |
  |    |      +-- optional management lock
  |    +--------- optional RBAC assignments
  +-------------- downstream workload resources
```

## Foundation Boundary

The resource group is the ARM lifecycle and access-control boundary consumed by downstream modules. Create it before workload resources and pass its name, location, ID, and tags through Terraform outputs rather than reconstructing them.

## State Ownership

One state should own the resource group. Downstream resource states may depend on it, but should not also declare it. Destroy ordering must remove dependent resources and locks before the group can be deleted safely.

## Lock Boundary

A lock applies to the resource group scope and is inherited by child resources. `CanNotDelete` is the safer general guard. `ReadOnly` can prevent normal Azure and Terraform operations, including service-managed updates.

## RBAC Boundary

Resource group RBAC applies to descendants unless overridden by Azure authorization behavior. Keep broad roles limited to approved principals, prefer stable object IDs, and use a separate cross-scope RBAC stack when access spans multiple resource groups or subscriptions.

## Tags

The caller owns the complete tag set. Root compositions should normalize enterprise tags before passing them to this module so downstream modules can inherit a plan-known baseline.
