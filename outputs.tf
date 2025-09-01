output "container_id" {
  description = "The ID of the storage container created for terraform backend state."
  value       = azurerm_storage_container.tfstate.id
}
output "container_name" {
  description = "Name of the storage container created for terraform backend state."
  value       = azurerm_storage_container.tfstate.name
}
#TODO: his property will be removed in v5 of the provider, and users are expected to directly use azurerm_storage_container.example.id. Though the id of azurerm_storage_container will change from the form of "https://example.blob.core.windows.net/container" to the resource manager id, only when the resource is created using the new storage_account_id. This means in your existing workspace, the id won't work.
#See https://github.com/hashicorp/terraform-provider-azurerm/pull/27733 for details.
output "container_resource_manager_id" {
  description = "The Resource Manager ID of the storage container created for terraform backend state."
  value       = azurerm_storage_container.tfstate.resource_manager_id
}
output "resource_group_name" {
  description = "Name of the resource group created for terraform backend state."
  value       = azurerm_resource_group.tfstate.name
}
output "storage_account_id" {
  description = "The ID of the storage account created for terraform backend state."
  value       = azurerm_storage_account.tfstate.id
}
output "storage_account_name" {
  description = "Name of the storage account created for terraform backend state."
  value       = azurerm_storage_account.tfstate.name
}