provider "azurerm" {
  storage_use_azuread = true

  features {}
}

# Basic Example for testing state container " 
# variables for region, state container name, network rules, cost center tag value are not defined
# Default values used instead. Resource group created with generated name. 

data "azurerm_client_config" "current" {}

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

    private_link_access = {
      # Test with Azure Storage Data Scanner example
      endpoint_resource_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Security/datascanners/storageDataScanner"
      endpoint_tenant_id   = data.azurerm_client_config.current.tenant_id
    }
  }

}

