# Log Analytics Quick Reference

- Secure access controls: `local_authentication_disabled`, `internet_ingestion_enabled`, `internet_query_enabled`.
- Governance: `allow_resource_only_permissions`, `cmk_for_query_forced`, `data_collection_rule_id`.
- Capacity Reservation requires a supported `reservation_capacity_in_gb_per_day`.
- Managed identity supports system-assigned and user-assigned modes.
- Explicit `tags` override `inherited_resource_group_tags`.
