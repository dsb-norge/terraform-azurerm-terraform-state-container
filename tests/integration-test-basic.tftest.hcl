provider "azurerm" {
  features {}
}

#TODO: change to 'apply' when terraform test can handle pervent_destroy behavior
#Github issue: https://github.com/hashicorp/terraform/issues/34960
run "plan" {
  command = plan

  module {
    source = "./examples/01-basic"
  }

  # We verify resource group name
  assert {
    condition     = length(output.resource_group_name) > 0
    error_message = "Resource group name was not created."
  }
}
