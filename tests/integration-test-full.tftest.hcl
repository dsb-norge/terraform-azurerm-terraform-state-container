provider "azurerm" {
  features {}
}

#TODO: change to 'apply' when terraform test can handle pervent_destroy behavior
#Github issue: https://github.com/hashicorp/terraform/issues/34960
run "plan" {
  command = plan

  module {
    source = "./examples/02-full"
  }

#TODO: uncomment blocks below when terraform test can handle pervent_destroy behavior
#Github issue: https://github.com/hashicorp/terraform/issues/34960

  # We verify that storage container was created.  
#  assert {
#    condition     = length(output.container_id) > 0
#    error_message = "Storage container was not created."
#  }

  # We verify cointainer manager id
#  assert {
#    condition     = length(output.container_resource_manager_id) > 0
#    error_message = "Container manager id was not created."
#  }

  # We verify resource group name
  assert {
    condition     = length(output.resource_group_name) > 0
    error_message = "Resource group name was not created."
  }

  # We verify storage account name
  assert {
    condition     = length(output.storage_account_name) > 0
    error_message = "Storage account name was not created."
  }
}
