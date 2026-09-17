# Event Hubs Geo-Disaster Recovery Example

Creates a Standard primary namespace and pairs it with an existing secondary namespace under a Geo-Disaster Recovery alias.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=rg-streaming-primary-prod" `
  -var="secondary_namespace_id=/subscriptions/.../providers/Microsoft.EventHub/namespaces/evhns-stream-secondary-prod-001"
```

The secondary namespace must already exist with compatible capacity, entities, network controls, and authorization. Geo-DR does not replicate event payloads or consumer checkpoints; maintain and rehearse a separate failover and recovery runbook.
