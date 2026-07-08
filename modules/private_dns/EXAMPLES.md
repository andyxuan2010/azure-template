# Private DNS Examples

## IPv4, IPv6, CNAME, and TXT

```hcl
zones = {
  "internal.contoso.com" = {
    a_records = {
      api = { ttl = 300, records = ["10.20.1.10"] }
    }
    aaaa_records = {
      api = { ttl = 300, records = ["2001:db8::10"] }
    }
    cname_records = {
      service = { ttl = 300, record = "api.internal.contoso.com" }
    }
    txt_records = {
      verification = { ttl = 300, records = ["verification=platform"] }
    }
  }
}
```
