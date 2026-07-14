mock_provider "azurerm" {}

variables {
  resource_group_name = "rg-platform-dev"
  inherited_resource_group_tags = {
    CostCenter = "platform"
  }
  zones = {
    "privatelink.vaultcore.azure.net" = {
      vnet_links = {}
      a_records = {
        vault = {
          ttl     = 300
          records = ["10.20.1.10"]
        }
      }
      aaaa_records = {
        vault6 = {
          ttl     = 300
          records = ["2001:db8::10"]
        }
      }
      cname_records = {
        alias = {
          ttl    = 300
          record = "vault.privatelink.vaultcore.azure.net"
        }
      }
      txt_records = {
        verification = {
          ttl     = 300
          records = ["verification=platform"]
        }
      }
    }
  }
}

run "plan" {
  command = plan

  assert {
    condition     = length(output.a_record_ids) == 1 && length(output.aaaa_record_ids) == 1 && length(output.cname_record_ids) == 1 && length(output.txt_record_ids) == 1
    error_message = "Expected one A, AAAA, CNAME, and TXT record."
  }

  assert {
    condition     = output.merged_tags.CostCenter == "platform"
    error_message = "Inherited resource-group tags were not applied."
  }
}
