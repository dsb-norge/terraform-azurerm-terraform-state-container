provider "azurerm" {
  features {}
}

# Basic Example for testing state container " 
# variables for region, state container name, network rules, cost center tag value are not defined
# Default values used instead. Resource group created with generated name. 


module "state_container" {
  source = "../../"

  subscription_number              = 1
  application_name                 = "basic-example"
  application_name_short           = "be"
  application_friendly_description = "Basic Example for testing state container module"
  environment_name                 = "qa"
  created_by_tag                   = "module example test"
}