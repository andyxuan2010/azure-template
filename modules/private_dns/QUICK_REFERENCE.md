# Private DNS Quick Reference

- Required: `resource_group_name`, `zones`.
- Zone children: `vnet_links`, `a_records`, `aaaa_records`, `cname_records`, `txt_records`.
- Record TTLs must be positive; A and AAAA addresses are validated.
- Explicit tags override inherited resource-group tags.
- Test with `terraform test`.
