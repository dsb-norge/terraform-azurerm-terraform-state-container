provider "azurerm" {
  features {}
}

#TODO: uncomment blocks below when terraform test can handle pervent_destroy behavior
#Github issue: https://github.com/hashicorp/terraform/issues/34960

#mock_provider "azurerm" {
#  alias = "mock"
#  override_data {
#    target = data.azurerm_subscription.current
#    values = {
#      id = "/subscriptions/12345678-1234-9876-4563-123456789012"
#    }
#  }
#}

run "application_friendly_description_can_not_be_empty" {
    command = plan

    variables {
        application_friendly_description = ""
    }

    # Expect the plan to fail
    expect_failures = [
        var.application_friendly_description,
    ]
}

run "application_name_can_not_be_empty" {
    command = plan

    variables {
        application_name = ""
    }

    # Expect the plan to fail
    expect_failures = [
        var.application_name,
    ]
}

run "application_name_short_can_not_be_empty" {
    command = plan

    variables {
        application_name_short = ""
    }

    # Expect the plan to fail
    expect_failures = [
        var.application_name_short,
    ]
}

run "created_by_tag_can_not_be_empty" {
    command = plan

    variables {
        created_by_tag = ""
    }

    # Expect the plan to fail
    expect_failures = [
        var.created_by_tag,
    ]
}

run "environment_name_can_not_be_empty" {
    command = plan

    variables {
        environment_name = ""
    }

    # Expect the plan to fail
    expect_failures = [
        var.environment_name,
    ]
}

run "subscription_number_can_not_be_less_than_1" {
    command = plan

    variables {
        subscription_number = 0
    }

    # Expect the plan to fail
    expect_failures = [
        var.subscription_number,
    ]
}

run "subscription_number_can_be_1" {
    command = plan

    variables {
        subscription_number = 1
    }

    assert {
        error_message = "The 'subscription_number' must be equal to or greater than 1."
        condition = azurerm_resource_group.tfstate.name == "rg-ss1-${var.application_name}-terraform-${var.environment_name}"
    }
}

run "azure_region_default_value" {
    command = plan

    assert {
        error_message = "The 'azure_region' default value is norwayeast."
        condition = azurerm_resource_group.tfstate.location == "norwayeast"
    }
}

run "azure_region_can_not_be_empty" {
    command = plan

    variables {
        azure_region = ""
    }

    # Expect the plan to fail
    expect_failures = [
        var.azure_region,
    ]
}

run "costcenter_tag_value_can_not_be_empty" {
    command = plan

    variables {
        costcenter_tag_value = ""
    }

    # Expect the plan to fail
    expect_failures = [
        var.costcenter_tag_value,
    ]
}

run "costcenter_tag_default_value" {
    command = plan

    assert {
        error_message = "The 'costcenter_tag_value' default value is 142."
        condition = azurerm_resource_group.tfstate.tags["costCenter"] == "142"
    }
}

run "costcenter_tag_value_can_not_be_empty" {
    command = plan

    variables {
        costcenter_tag_value = ""
    }

    # Expect the plan to fail
    expect_failures = [
        var.costcenter_tag_value,
    ]
}

run "network_rules_default_action" {
    command = plan

    assert {
        error_message = "The 'default_action' default value is Deny."
        condition = azurerm_storage_account_network_rules.tfstate[0].default_action == "Deny"
    }
}

run "network_rules_default_allow_dsb_public_ips" {
    command = plan

    assert {
        error_message = "The default 'ip_rules' value is 91.229.21.0/24."
        condition = tolist(azurerm_storage_account_network_rules.tfstate[0].ip_rules)[0] == "91.229.21.0/24"
    }
}

#TODO: should be apply. 
#run "network_rules_default_bypass" {
#    command = apply

#    assert {
#        error_message = "The default 'bypass' value is null."
#        condition = azurerm_storage_account_network_rules.tfstate[0].bypass == null
#    }
#}

run "network_rules_default_action_allow_allowed" {
    command = plan

    variables {
        network_rules = {
            bypass                      = null
            default_action              = "Allow"
            ip_rules                    = ["224.0.0.1/24"]
            virtual_network_subnet_ids  = null
        }
    }

    assert {
        error_message = "Allow is a valid value for network_rules.default_action."
        condition = azurerm_storage_account_network_rules.tfstate[0].default_action == "Allow"
    }
}

run "network_rules_default_action_deny_allowed" {
    command = plan

    variables {
        network_rules = {
            bypass                      = null
            default_action              = "Deny"
            ip_rules                    = ["224.0.0.1/24"]
            virtual_network_subnet_ids  = null

        }
    }

    assert {
        error_message = "Deny is a valid value for network_rules.default_action."
        condition = azurerm_storage_account_network_rules.tfstate[0].default_action == "Deny"
    }
}

run "network_rules_default_action_not_allowed" {
    command = plan

    variables {
        network_rules = {
            bypass                      = null
            default_action              = "Not Allowed"
            ip_rules                    = ["224.0.0.1/24"]
            virtual_network_subnet_ids  = null

        }
    }

    # Expect the plan to fail  
    expect_failures = [
        var.network_rules,
    ]
}

run "network_rules_bypass_logging_allowed" {
    command = plan

    variables {
        network_rules = {
            bypass                      = ["Logging"]
            default_action              = "Deny"
            ip_rules                    = ["224.0.0.1/24"]
            virtual_network_subnet_ids  = null
        }
    }

    assert {
        error_message = "Logging is a valid value for network_rules.bypass."
        condition = tolist(azurerm_storage_account_network_rules.tfstate[0].bypass)[0] == "Logging"
    }
}

run "network_rules_bypass_metrics_allowed" {
    command = plan

    variables {
        network_rules = {
            bypass                      = ["Metrics"]
            default_action              = "Deny"
            ip_rules                    = ["224.0.0.1/24"]
            virtual_network_subnet_ids  = null
        }
    }

    assert {
        error_message = "Metrics is a valid value for network_rules.bypass."
        condition = tolist(azurerm_storage_account_network_rules.tfstate[0].bypass)[0] == "Metrics"
    }
}

run "network_rules_bypass_azureservices_allowed" {
    command = plan

    variables {
        network_rules = {
            bypass                      = ["AzureServices"]
            default_action              = "Deny"
            ip_rules                    = ["224.0.0.1/24"]
            virtual_network_subnet_ids  = null
        }
    }

    assert {
        error_message = "AzureServices is a valid value for network_rules.bypass."
        condition = tolist(azurerm_storage_account_network_rules.tfstate[0].bypass)[0] == "AzureServices"
    }
}

run "network_rules_bypass_azure_services" {
    command = plan

    variables {
        network_rules = {
            bypass                      = ["AzureServices"]
            default_action              = "Deny"
            ip_rules                    = ["224.0.0.1"]
            virtual_network_subnet_ids  = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myResourceGroup/providers/Microsoft.Storage/storageAccounts/myStorageAccount"]
        }
    }

    assert {
        error_message = "Bypass should be set to AzureServices."
        condition = tolist(azurerm_storage_account_network_rules.tfstate[0].bypass)[0] == "AzureServices"
    }
}

run "network_rules_bypass_none_allowed" {
    command = plan

    variables {
        network_rules = {
            bypass                      = ["None"]
            default_action              = "Deny"
            ip_rules                    = ["224.0.0.1/24"]
            virtual_network_subnet_ids  = null
        }
    }

    assert {
        error_message = "None is a valid value for network_rules.bypass."
        condition = tolist(azurerm_storage_account_network_rules.tfstate[0].bypass)[0] == "None"
    }
}

run "network_rules_bypass_not_allowed" {
    command = plan

    variables {
        network_rules = {
            bypass                      = ["Not Allowed"]
            default_action              = "Deny"
            ip_rules                    = ["224.0.0.1/24"]
            virtual_network_subnet_ids  = null
        }
    }

    # Expect the plan to fail
    expect_failures = [
        var.network_rules,
    ]
}

run "network_rules_ip_rules_invalid_cidr" {
    command = plan

    variables {
        network_rules = {
            bypass                      = null
            default_action              = "Deny"
            ip_rules                    = ["224.0.0.1/224"]
            virtual_network_subnet_ids  = null
        }
    }

    # Expect the plan to fail
    expect_failures = [
        var.network_rules,
    ]
}

run "network_rules_ip_rules_invalid_cidr_prefix" {
    command = plan

    variables {
        network_rules = {
            bypass                      = null
            default_action              = "Deny"
            ip_rules                    = ["224.0.0.252/32"]
            virtual_network_subnet_ids  = null
        }
    }

    # Expect the plan to fail
    expect_failures = [
        var.network_rules,
    ]
}

run "network_rules_ip_rules_invalid_cidr_prefix_31" {
    command = plan

    variables {
        network_rules = {
            bypass                      = null
            default_action              = "Deny"
            ip_rules                    = ["224.0.0.248/31"]
            virtual_network_subnet_ids  = null
        }
    }

    # Expect the plan to fail
    expect_failures = [
        var.network_rules,
    ]
}

run "network_rules_ip_rules_invalid_ipv4" {
    command = plan

    variables {
        network_rules = {
            bypass                      = null
            default_action              = "Deny"
            ip_rules                    = ["224.0.0.256/24"]
            virtual_network_subnet_ids  = null
        }
    }

    # Expect the plan to fail
    expect_failures = [
        var.network_rules,
    ]
}

run "network_rules_multiple_ip_rules" {
    command = plan

    variables {
        network_rules = {
            bypass                      = null
            default_action              = "Deny"
            ip_rules                    = ["224.0.0.1/28", "225.0.0.2"]
            virtual_network_subnet_ids  = null
        }
    }

    assert {
        error_message = "IP rules should include 224.0.0.1 and 224.0.0.2."
        condition = length(azurerm_storage_account_network_rules.tfstate[0].ip_rules) == 2
    }
}

run "network_rules_ip_rules_valid_cidr" {
    command = plan

    variables {
        network_rules = {
            bypass                      = null
            default_action              = "Deny"
            ip_rules                    = ["224.0.0.1"]
            virtual_network_subnet_ids  = null
        }
    }

    assert {
        error_message = "Valid IPv4 address provided for network_rules.ip_rules."
        condition = tolist(azurerm_storage_account_network_rules.tfstate[0].ip_rules)[0] == "224.0.0.1"
    }
}

run "network_rules_virtual_network_subnet_ids_not_allowed" {
    command = plan

    variables {
        network_rules = {
            bypass                      = null
            default_action              = "Deny"
            ip_rules                    = ["224.0.0.1"]
            virtual_network_subnet_ids  = ["Not Allowed"]
        }
    }

    # Expect the plan to fail
    expect_failures = [
        var.network_rules,
    ]
}

run "network_rules_virtual_network_subnet_ids_allowed" {
    command = plan

    variables {
        network_rules = {
            bypass                      = null
            default_action              = "Deny"
            ip_rules                    = ["224.0.0.1"]
            virtual_network_subnet_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myResourceGroup/providers/Microsoft.Storage/storageAccounts/myStorageAccount"]
        }
    }

    assert {
        error_message = "Network rules virtual network subnet ID can not be null and must have length greater than 50."
        condition = tolist(azurerm_storage_account_network_rules.tfstate[0].virtual_network_subnet_ids)[0] == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myResourceGroup/providers/Microsoft.Storage/storageAccounts/myStorageAccount"
    }
}

run "network_rules_invalid_resource_id" {
    command = plan

    variables {
        network_rules = {
            bypass                      = null
            default_action              = "Deny"
            ip_rules                    = ["224.0.0.1"]
            virtual_network_subnet_ids  = ["invalid/resource/id"]
        }
    }

    # Expect the plan to fail
    expect_failures = [
        var.network_rules,
    ]
}

run "state_container_name_can_not_be_empty" {
    command = plan

    variables {
        state_container_name = ""
    }

    # Expect the plan to fail
    expect_failures = [
        var.state_container_name,
    ]
}

run "state_container_name_default_value" {
    command = plan

    assert {
        error_message = "The 'state_container_name' default value is terraform-remote-backend-state."
        condition = azurerm_storage_container.tfstate.name == "terraform-remote-backend-state"
    }
}

#TODO: uncomment blocks below when terraform test can handle pervent_destroy behavior
/*
run "it_should_output_container_id" {
    command = apply

    providers = {
        azurerm = azurerm.mock
    }

    assert {
        error_message = "Storage container id output is missing"
        condition = length(azurerm_storage_container.tfstate.id) > 0
    }
}

run "it_should_output_container_resource_manager_id" {
    command = apply

    providers = {
        azurerm = azurerm.mock
    }

    assert {
        error_message = "Storage container resource manager id output is missing"
        condition = length(azurerm_storage_container.tfstate.container_resource_manager_id) > 0
    }
}

run "it_should_output_container_name" {
    command = apply

    providers = {
        azurerm = azurerm.mock
    }

    assert {
        error_message = "Storage container name output is missing"
        condition = length(azurerm_storage_container.tfstate.name) > 0
    }
}

run "it_should_output_resource_group_name" {
    command = apply

    providers = {
        azurerm = azurerm.mock
    }

    assert {
        error_message = "Resource group name output is missing"
        condition = length(azurerm_resource_group.tfstate.name) > 0
    }
}

run "it_should_output_storage_account_name" {
    command = apply

    providers = {
        azurerm = azurerm.mock
    }

    assert {
        error_message = "Storage account name output is missing"
        condition = length(azurerm_storage_account.tfstate.name) > 0
    }
}
*/