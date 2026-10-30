# Service Bus Topics and Subscriptions

Creates one Standard topic with separate billing and fulfillment subscriptions.

Run `terraform init -backend=false` and `terraform validate` for local validation. Before apply, supply an existing resource group and globally unique namespace name, then add application data-plane identities and any required subscription filters outside this module. Standard Service Bus is billable.
