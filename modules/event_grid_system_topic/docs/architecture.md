# Event Grid System Topic architecture

The module owns one `azurerm_eventgrid_system_topic` resource for an existing Azure event source. It does not create or manage the source resource, Event Grid event subscriptions, delivery endpoints, dead-letter storage, custom topics, domains, private endpoints, or downstream RBAC.

## Resource boundary

```text
Existing Azure source resource
        |
        v
azurerm_eventgrid_system_topic.this
  |- topic type and source resource ID
  |- optional managed identity
  `- inherited and caller-supplied tags
        |
        v
Caller-owned event subscriptions and delivery endpoints
```

The module reads the resource group's location when `location` is empty and reads its tags when tag inheritance is enabled without plan-known tags. Supplying both `location` and `inherited_resource_group_tags` avoids those lookups during plan-only composition.

## Topic type and source ownership

`topic_type` must match the Azure resource represented by `source_resource_id`, for example `Microsoft.Storage.StorageAccounts` for a storage account. Azure validates whether the selected topic type and source resource are compatible. The source must exist before the system topic is created.

Event subscriptions are intentionally separate. Their delivery endpoint, filters, retry policy, dead-letter destination, and identity permissions are workload-specific and should be owned by the composition that understands those requirements.

## Identity and security considerations

- Managed identity is disabled by default and receives no RBAC assignments from this module.
- A user-assigned identity requires at least one full identity resource ID.
- Grant only the downstream permissions required by the selected event delivery path.
- Keep event subscription destinations, webhook secrets, and dead-letter storage controls in the owning workload composition.

See the module [README](../README.md) for inputs, outputs, examples, and validation commands.
