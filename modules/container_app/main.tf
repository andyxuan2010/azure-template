# Copyright (c) CCOE-Azure.
# SPDX-License-Identifier: Proprietary
#
# Module: containerapp
# Description: Deploys Azure Container Apps for serverless container workloads on Azure.
#              The module supports container definitions, ingress, revisions, secrets, identities, scaling, registry integration, optional managed environment references, diagnostics, and resource group tag inheritance for governance alignment.
# Owner: Cloud Center of Excellence (CCOE)
# Maintainer: Andy Xuan@CCOE
# Repository: CCOE-Azure/azure-template
#
# Created: 2026-07-02
# Modified: 2026-07-08
# Version: 1.3.0
#
# Change History:
# - 2026-07-02 v1.0.0: Established reusable containerapp module baseline for the CCOE Azure IaC template library.
# - 2026-07-08 v1.0.0: Added standardized module metadata header with ownership, maintainer, license, dates, version, and change history.
#
# This Terraform module is maintained as part of the CCOE Azure IaC template library.
# Use, modification, and distribution are governed by the repository license and organizational policy.

resource "azurerm_container_app" "this" {
  name                         = local.container_app_name
  resource_group_name          = local.resource_group_name
  container_app_environment_id = trimspace(var.container_app_environment_id)
  revision_mode                = var.revision_mode
  workload_profile_name        = local.workload_profile_name_resolved
  max_inactive_revisions       = var.max_inactive_revisions
  tags                         = local.tags

  dynamic "identity" {
    for_each = local.identity_enabled ? [1] : []

    content {
      type         = var.identity_type
      identity_ids = length(local.identity_ids) > 0 ? local.identity_ids : null
    }
  }

  dynamic "secret" {
    for_each = var.secrets

    content {
      name                = secret.value.name
      value               = try(secret.value.value, null)
      key_vault_secret_id = try(secret.value.key_vault_secret_id, null)
      identity            = try(secret.value.identity, null)
    }
  }

  dynamic "registry" {
    for_each = var.registries

    content {
      server               = registry.value.server
      username             = try(registry.value.username, null)
      password_secret_name = try(registry.value.password_secret_name, null)
      identity             = try(registry.value.identity, null)
    }
  }

  dynamic "dapr" {
    for_each = var.dapr == null ? [] : [var.dapr]

    content {
      app_id       = dapr.value.app_id
      app_port     = try(dapr.value.app_port, null)
      app_protocol = try(dapr.value.app_protocol, null)
    }
  }

  dynamic "ingress" {
    for_each = var.ingress == null ? [] : [var.ingress]

    content {
      external_enabled           = ingress.value.external_enabled
      target_port                = ingress.value.target_port
      transport                  = ingress.value.transport
      allow_insecure_connections = ingress.value.allow_insecure_connections
      client_certificate_mode    = try(ingress.value.client_certificate_mode, null)
      exposed_port               = try(ingress.value.exposed_port, null)

      dynamic "traffic_weight" {
        for_each = local.ingress_traffic_weights

        content {
          percentage      = traffic_weight.value.percentage
          latest_revision = try(traffic_weight.value.latest_revision, null)
          revision_suffix = try(traffic_weight.value.revision_suffix, null)
          label           = try(traffic_weight.value.label, null)
        }
      }

      dynamic "ip_security_restriction" {
        for_each = ingress.value.ip_security_restrictions

        content {
          name             = ip_security_restriction.value.name
          action           = ip_security_restriction.value.action
          ip_address_range = ip_security_restriction.value.ip_address_range
          description      = try(ip_security_restriction.value.description, null)
        }
      }

      dynamic "cors" {
        for_each = try(ingress.value.cors, null) == null ? [] : [ingress.value.cors]

        content {
          allowed_origins           = try(cors.value.allowed_origins, [])
          allowed_methods           = try(cors.value.allowed_methods, [])
          allowed_headers           = try(cors.value.allowed_headers, [])
          exposed_headers           = try(cors.value.exposed_headers, [])
          allow_credentials_enabled = try(cors.value.allow_credentials_enabled, false)
          max_age_in_seconds        = try(cors.value.max_age_in_seconds, null)
        }
      }
    }
  }

  template {
    min_replicas                     = var.min_replicas
    max_replicas                     = var.max_replicas
    revision_suffix                  = local.revision_suffix_resolved
    termination_grace_period_seconds = var.termination_grace_period_seconds
    cooldown_period_in_seconds       = var.cooldown_period_in_seconds
    polling_interval_in_seconds      = var.polling_interval_in_seconds

    dynamic "container" {
      for_each = var.containers

      content {
        name              = container.value.name
        image             = container.value.image
        cpu               = container.value.cpu
        memory            = container.value.memory
        args              = try(container.value.args, null)
        command           = try(container.value.command, null)
        ephemeral_storage = try(container.value.ephemeral_storage, null)

        dynamic "env" {
          for_each = container.value.env

          content {
            name        = env.value.name
            value       = try(env.value.value, null)
            secret_name = try(env.value.secret_name, null)
          }
        }

        dynamic "volume_mounts" {
          for_each = container.value.volume_mounts

          content {
            name     = volume_mounts.value.name
            path     = volume_mounts.value.path
            sub_path = try(volume_mounts.value.sub_path, null)
          }
        }
      }
    }

    dynamic "init_container" {
      for_each = var.init_containers

      content {
        name              = init_container.value.name
        image             = init_container.value.image
        cpu               = try(init_container.value.cpu, null)
        memory            = try(init_container.value.memory, null)
        args              = try(init_container.value.args, null)
        command           = try(init_container.value.command, null)
        ephemeral_storage = try(init_container.value.ephemeral_storage, null)

        dynamic "env" {
          for_each = init_container.value.env

          content {
            name        = env.value.name
            value       = try(env.value.value, null)
            secret_name = try(env.value.secret_name, null)
          }
        }

        dynamic "volume_mounts" {
          for_each = init_container.value.volume_mounts

          content {
            name     = volume_mounts.value.name
            path     = volume_mounts.value.path
            sub_path = try(volume_mounts.value.sub_path, null)
          }
        }
      }
    }

    dynamic "volume" {
      for_each = var.volumes

      content {
        name          = volume.value.name
        storage_type  = volume.value.storage_type
        storage_name  = try(volume.value.storage_name, null)
        mount_options = try(volume.value.mount_options, null)
      }
    }

    dynamic "http_scale_rule" {
      for_each = var.http_scale_rules

      content {
        name                = http_scale_rule.value.name
        concurrent_requests = http_scale_rule.value.concurrent_requests

        dynamic "authentication" {
          for_each = http_scale_rule.value.authentication

          content {
            secret_name       = authentication.value.secret_name
            trigger_parameter = authentication.value.trigger_parameter
          }
        }
      }
    }

    dynamic "tcp_scale_rule" {
      for_each = var.tcp_scale_rules

      content {
        name                = tcp_scale_rule.value.name
        concurrent_requests = tcp_scale_rule.value.concurrent_requests

        dynamic "authentication" {
          for_each = tcp_scale_rule.value.authentication

          content {
            secret_name       = authentication.value.secret_name
            trigger_parameter = authentication.value.trigger_parameter
          }
        }
      }
    }

    dynamic "custom_scale_rule" {
      for_each = var.custom_scale_rules

      content {
        name             = custom_scale_rule.value.name
        custom_rule_type = custom_scale_rule.value.custom_rule_type
        metadata         = custom_scale_rule.value.metadata
        identity_id      = try(custom_scale_rule.value.identity_id, null)

        dynamic "authentication" {
          for_each = custom_scale_rule.value.authentication

          content {
            secret_name       = authentication.value.secret_name
            trigger_parameter = authentication.value.trigger_parameter
          }
        }
      }
    }

    dynamic "azure_queue_scale_rule" {
      for_each = var.azure_queue_scale_rules

      content {
        name         = azure_queue_scale_rule.value.name
        queue_name   = azure_queue_scale_rule.value.queue_name
        queue_length = azure_queue_scale_rule.value.queue_length

        dynamic "authentication" {
          for_each = azure_queue_scale_rule.value.authentication

          content {
            secret_name       = authentication.value.secret_name
            trigger_parameter = authentication.value.trigger_parameter
          }
        }
      }
    }
  }
}
