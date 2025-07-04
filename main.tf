locals {
  application_name_full             = "${var.application_name}-terraform"
  application_name_short_full       = "${var.application_name_short}-tf"
  application_name_short_full_alnum = join("", regexall("[[:alnum:]]", local.application_name_short_full))
  environment_name_alnum            = join("", regexall("[[:alnum:]]", var.environment_name))
  resource_group_name               = "rg-ss${var.subscription_number}-${local.application_name_full}-${var.environment_name}"
  storage_account_name              = lower(substr("stss${var.subscription_number}${local.application_name_short_full_alnum}${local.environment_name_alnum}", 0, 24))
  common_tags = {
    ApplicationName = var.application_name
    CreatedBy       = var.created_by_tag
    Environment     = var.environment_name
  }

  # For more information about DSB mandatory tags see confluence page : https://dsbno.atlassian.net/wiki/spaces/DSBTB/pages/2391179644/Bruk+av+tags
  rg_mandatory_tags = {
    costCenter = var.costcenter_tag_value # defaut set to IKT
    #TODO: Uncomment the following lines when the systemId tag is available
    #    systemId   = var.systemid_tag
  }
}
resource "azurerm_resource_group" "tfstate" {
  location = var.azure_region
  name     = local.resource_group_name
  tags = merge(local.common_tags, local.rg_mandatory_tags, {
    Description = "Resource group with terraform backend state for ${var.application_friendly_description}."
  })

  lifecycle {
    prevent_destroy = true
  }
}
resource "azurerm_storage_account" "tfstate" {
  account_replication_type        = "LRS"
  account_tier                    = "Standard"
  location                        = var.azure_region
  name                            = local.storage_account_name
  resource_group_name             = azurerm_resource_group.tfstate.name
  allow_nested_items_to_be_public = false
  default_to_oauth_authentication = true
  shared_access_key_enabled       = false
  tags = merge(local.common_tags, {
    Description = "Storage account with terraform backend state for ${var.application_friendly_description}."
  })

  blob_properties {
    change_feed_enabled           = true
    change_feed_retention_in_days = 90
    last_access_time_enabled      = true
    versioning_enabled            = true

    delete_retention_policy {
      days = 30
    }
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
    prevent_destroy = true
  }
}
resource "azurerm_storage_account_network_rules" "tfstate" {
  count = var.network_rules != null ? 1 : 0

  default_action             = var.network_rules.default_action
  storage_account_id         = azurerm_storage_account.tfstate.id
  bypass                     = var.network_rules.bypass
  ip_rules                   = var.network_rules.ip_rules
  virtual_network_subnet_ids = var.network_rules.virtual_network_subnet_ids

  dynamic "private_link_access" {
    for_each = (
      var.network_rules != null && var.network_rules.private_link_access != null
      ? tolist([var.network_rules.private_link_access])
      : []
    )

    content {
      endpoint_resource_id = private_link_access.value.endpoint_resource_id
      endpoint_tenant_id   = private_link_access.value.endpoint_tenant_id
    }
  }
  # tags not supported
}
resource "azurerm_storage_container" "tfstate" {
  name                  = var.state_container_name
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
  # tags not supported
  lifecycle {
    prevent_destroy = true
  }
}
