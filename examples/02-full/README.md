<!-- BEGIN_TF_DOCS -->



```hcl
provider "azurerm" {
  storage_use_azuread = true

  features {}
}

# Basic Example for testing state container " 
# variables for region, state container name, network rules, cost center tag value are not defined
# Default values used instead. Resource group created with generated name. 


module "state_container" {
  source = "../../"

  subscription_number              = 13
  application_name                 = "full-example"
  application_name_short           = "fe"
  application_friendly_description = "Full Example for testing of state container module"
  environment_name                 = "qa"
  created_by_tag                   = "module example test"
  azure_region                     = "northeurope"
  costcenter_tag_value             = "888"
  state_container_name             = "full-example-state-container"
  network_rules = {
    default_action             = "Deny"
    bypass                     = []
    ip_rules                   = []
    virtual_network_subnet_ids = []
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