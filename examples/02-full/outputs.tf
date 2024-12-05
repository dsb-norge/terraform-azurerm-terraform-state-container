output "container_id" {
  description = "The ID of the storage container created for terraform backend state."
  value       = module.state_container.container_id
}

output "container_name" {
  description = "Name of the storage container created for terraform backend state."
  value       = module.state_container.container_name
}

output "container_resource_manager_id" {
  description = "The Resource Manager ID of the storage container created for terraform backend state."
  value       = module.state_container.container_resource_manager_id
}

output "resource_group_name" {
  description = "Name of the resource group created for terraform backend state."
  value       = module.state_container.resource_group_name
}

output "storage_account_name" {
  description = "Name of the storage account created for terraform backend state."
  value       = module.state_container.storage_account_name

}