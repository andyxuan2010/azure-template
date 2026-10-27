# Copyright (c) CCOE-Azure.
# SPDX-License-Identifier: Proprietary
#
# Module: frontdoor
# Description: Creates an Azure Front Door profile and single-origin HTTPS route.
# Owner: Cloud Center of Excellence (CCOE)
# Maintainer: Andy Xuan@CCOE
# Repository: CCOE-Azure/azure-template
#
# Created: 2026-10-27
# Modified: 2026-10-27
# Version: 1.0.0
#
# This Terraform module is maintained as part of the CCOE Azure IaC template library.
# Use, modification, and distribution are governed by the repository license and organizational policy.

resource "azurerm_cdn_frontdoor_profile" "this" {
  name                = local.profile_name
  resource_group_name = var.resource_group_name
  sku_name            = var.sku_name
  tags                = local.tags
}

resource "azurerm_cdn_frontdoor_endpoint" "this" {
  name                     = local.endpoint_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id
  enabled                  = var.endpoint_enabled
  tags                     = local.tags
}

resource "azurerm_cdn_frontdoor_origin_group" "this" {
  name                                                      = local.origin_group_name
  cdn_frontdoor_profile_id                                  = azurerm_cdn_frontdoor_profile.this.id
  session_affinity_enabled                                  = var.session_affinity_enabled
  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = var.restore_traffic_time_to_healed_or_new_endpoint_in_minutes

  load_balancing {
    additional_latency_in_milliseconds = var.additional_latency_in_milliseconds
    sample_size                        = var.sample_size
    successful_samples_required        = var.successful_samples_required
  }

  dynamic "health_probe" {
    for_each = var.health_probe_enabled ? [true] : []
    content {
      protocol            = var.health_probe_protocol
      interval_in_seconds = var.health_probe_interval_in_seconds
      request_type        = var.health_probe_request_type
      path                = var.health_probe_path
    }
  }
}

resource "azurerm_cdn_frontdoor_origin" "this" {
  name                           = local.origin_name
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.this.id
  enabled                        = var.origin_enabled
  certificate_name_check_enabled = var.certificate_name_check_enabled
  host_name                      = var.origin_hostname
  origin_host_header             = var.origin_host_header == null ? var.origin_hostname : var.origin_host_header
  http_port                      = var.origin_http_port
  https_port                     = var.origin_https_port
  priority                       = var.origin_priority
  weight                         = var.origin_weight

  lifecycle {
    precondition {
      condition     = var.private_link == null || var.sku_name == "Premium_AzureFrontDoor"
      error_message = "Private Link origins require sku_name = Premium_AzureFrontDoor."
    }

    precondition {
      condition     = var.private_link == null || var.certificate_name_check_enabled
      error_message = "Certificate name checks must be enabled for Private Link origins."
    }
  }

  dynamic "private_link" {
    for_each = var.private_link == null ? [] : [var.private_link]
    content {
      private_link_target_id = private_link.value.private_link_target_id
      location               = private_link.value.location
      request_message        = private_link.value.request_message
      target_type            = private_link.value.target_type
    }
  }
}

resource "azurerm_cdn_frontdoor_route" "this" {
  name                            = local.route_name
  cdn_frontdoor_endpoint_id       = azurerm_cdn_frontdoor_endpoint.this.id
  cdn_frontdoor_origin_group_id   = azurerm_cdn_frontdoor_origin_group.this.id
  cdn_frontdoor_origin_ids        = [azurerm_cdn_frontdoor_origin.this.id]
  cdn_frontdoor_custom_domain_ids = var.cdn_frontdoor_custom_domain_ids
  enabled                         = var.route_enabled
  forwarding_protocol             = var.forwarding_protocol
  https_redirect_enabled          = var.https_redirect_enabled
  patterns_to_match               = var.patterns_to_match
  supported_protocols             = var.supported_protocols
  link_to_default_domain          = var.link_to_default_domain

  lifecycle {
    precondition {
      condition     = !var.https_redirect_enabled || (contains(var.supported_protocols, "Http") && contains(var.supported_protocols, "Https"))
      error_message = "https_redirect_enabled requires both Http and Https in supported_protocols."
    }

  }
}
