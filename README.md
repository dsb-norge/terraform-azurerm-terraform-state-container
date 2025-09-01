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
<!-- markdownlint-disable MD033 -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.0.0, < 5.0.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.tfstate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_storage_account.tfstate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_account_network_rules.tfstate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_network_rules) | resource |
| [azurerm_storage_container.tfstate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |

<!-- markdownlint-disable MD013 -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_friendly_description"></a> [application\_friendly\_description](#input\_application\_friendly\_description) | Friendly description of the application to use when naming resources. | `string` | n/a | yes |
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | Name of the application to use when naming resources. | `string` | n/a | yes |
| <a name="input_application_name_short"></a> [application\_name\_short](#input\_application\_name\_short) | Short name of the application to use when naming resources eg. for storage account name. | `string` | n/a | yes |
| <a name="input_created_by_tag"></a> [created\_by\_tag](#input\_created\_by\_tag) | The value of createdBy Tag | `string` | n/a | yes |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | Name of the environment to use when naming resources. | `string` | n/a | yes |
| <a name="input_subscription_number"></a> [subscription\_number](#input\_subscription\_number) | Subscription number to use when naming resources. | `number` | n/a | yes |
| <a name="input_azure_region"></a> [azure\_region](#input\_azure\_region) | Name of the Azure region to use when naming resources. | `string` | `"norwayeast"` | no |
| <a name="input_costcenter_tag_value"></a> [costcenter\_tag\_value](#input\_costcenter\_tag\_value) | The value of the costCenter tag.<br/>This is DSB mandatory tag identifying resource group cost center affiliation.<br/>Default value is set to DSB IKT cost center. | `string` | `"142"` | no |
| <a name="input_network_rules"></a> [network\_rules](#input\_network\_rules) | Network rules to apply to the terraform backend state storage account. | <pre>object({<br/>    default_action             = string<br/>    bypass                     = list(string)<br/>    ip_rules                   = list(string)<br/>    virtual_network_subnet_ids = list(string)<br/>    private_link_access = optional(object({<br/>      endpoint_resource_id = string<br/>      endpoint_tenant_id   = string<br/>    }))<br/>  })</pre> | <pre>{<br/>  "bypass": null,<br/>  "default_action": "Deny",<br/>  "ip_rules": [<br/>    "91.229.21.0/24"<br/>  ],<br/>  "virtual_network_subnet_ids": null<br/>}</pre> | no |
| <a name="input_state_container_name"></a> [state\_container\_name](#input\_state\_container\_name) | Name of the state container to use when naming resources. | `string` | `"terraform-remote-backend-state"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_id"></a> [container\_id](#output\_container\_id) | The ID of the storage container created for terraform backend state. |
| <a name="output_container_name"></a> [container\_name](#output\_container\_name) | Name of the storage container created for terraform backend state. |
| <a name="output_container_resource_manager_id"></a> [container\_resource\_manager\_id](#output\_container\_resource\_manager\_id) | The Resource Manager ID of the storage container created for terraform backend state. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Name of the resource group created for terraform backend state. |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | The ID of the storage account created for terraform backend state. |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | Name of the storage account created for terraform backend state. |

## Modules

No modules.
<!-- END_TF_DOCS -->