# Terraform module for creation of Terraform remote state container in Azure

Terraform module to create storage account with container to store Terraform state remotely in azure.  

Module has following features:  

- Create resource group for storage account.  
- Create storage account with private container for state.  
- Create Delete lock on resources.  
- Create network rules for storage account.  
- Tag resources with createBy and costCenter tags.  

## Usage

Refer to [examples](https://github.com/dsb-norge/terraform-azurerm-terraform-state-container/tree/main/examples) for usage of module.

<!-- BEGIN_TF_DOCS -->



```hcl
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
  account_replication_type = "LRS"
  account_tier             = "Standard"
  location                 = var.azure_region
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.tfstate.name
  tags = merge(local.common_tags, {
    Description = "Storage account with terraform backend state for ${var.application_friendly_description}."
  })

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
```
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_id"></a> [container\_id](#output\_container\_id) | The ID of the storage container created for terraform backend state. |
| <a name="output_container_name"></a> [container\_name](#output\_container\_name) | Name of the storage container created for terraform backend state. |
| <a name="output_container_resource_manager_id"></a> [container\_resource\_manager\_id](#output\_container\_resource\_manager\_id) | The Resource Manager ID of the storage container created for terraform backend state. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Name of the resource group created for terraform backend state. |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | Name of the storage account created for terraform backend state. |
<!-- END_TF_DOCS -->