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

## Cost and risk

- The primary namespace is `Standard` SKU: billed per throughput unit per hour (the `capacity` input) plus per million ingress events. The pre-existing secondary namespace is billed the same way on its own terms, so Geo-DR means paying for two namespaces. The pairing (`azurerm_eventhub_namespace_disaster_recovery_config`) has no separate charge.
- Risk: the secondary namespace must exist and be compatible before apply, and pairing can take a while to provision; a namespace with an active pairing cannot be deleted until the pairing is broken. `public_network_access_enabled = false` and `local_authentication_enabled = false` mean clients need private connectivity and Microsoft Entra authentication; if the secondary does not match, failover will break clients. Failover is a manual, one-way operation that changes which namespace is active, and event data is not replicated.
